package main

import (
	"embed"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"rsc.io/quote"
)

func run(msg string, cmd *exec.Cmd) {
	fmt.Println(msg)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stdout
	if err := cmd.Run(); err != nil {
		fmt.Println("Error:", err)
	}
	fmt.Println("")
}

// Sets up the shared Docker Compose network.
//
// Creates the named (attachable) network if it doesn't exist.
func setupNetwork(composeNetwork string) {
	networks := exec.Command("docker", "network", "ls")
	output, err := networks.Output()
	if err != nil {
		log.Println(err)
	}

	matches := regexp.MustCompile(composeNetwork).FindStringSubmatch(string(output))
	if len(matches) >= 1 {
		fmt.Printf("Docker network %s already exists, joining.\n", composeNetwork)
	} else {
		fmt.Println("Create user-defined network")
		createNewnet := exec.Command("docker", "network", "create", "--driver", "bridge", "--attachable", composeNetwork)
		if output, err := createNewnet.Output(); err != nil {
			fmt.Println("Error:", err)
		} else {
			fmt.Printf("Otuput: %s\n", output)
		}
	}
}

func showHelp() {
	fmt.Println("Help placeholder")
}

// Project ..  Environment variables used by Docker Compose.
type Project struct {
	// Path to Docker Compose specifications.
	composeSpecs string
	// Options passed to Docker Compose command.
	composeOptions string
	// Shared network name.
	network string
	// Path to source code directory, mounted into containers.
	source string
	// Name of current directory, used for service aliases.
	name string
	// Expected input by the php-fpm service, tells XDebug address where to find IDE.
	// php-fpm service located in docker-compose.vsd.yml file.
	// https://www.reddit.com/r/bashonubuntuonwindows/comments/c871g7/command_to_get_virtual_machine_ip_in_wsl2/
	xdebug string
}

//go:embed docker
var dockerfs embed.FS

func embedRead(filename string) []byte {
	file, e := dockerfs.ReadFile(filename)
	if e != nil {
		panic(e)
	}
	return file
}

// Search destination for compose spec file, copies from source in embed filesystem into destination if not found.
func provideOverride(source string, destination string) {
	if _, err := os.Stat(destination); os.IsNotExist(err) {
		fmt.Printf("Required file %s not found, copying into %s \n", source, destination)
		override := embedRead(source)
		err := os.WriteFile(destination, override, 0744)
		if err != nil {
			panic(err)
		}
	} else {
		fmt.Printf("Required file %s found. \n", source)
	}
}

// Gather information used by all sub-commands.
func bootstrap() Project {
	composeNetwork := `VSD`

	// Provide shared services override, if not present already.
	provideOverride("docker/docker-compose.override.yml", "docker-compose.override.yml")

	composeOptsPtr := flag.String("options", "--file=docker-compose.override.yml", "Options passed to Docker Compose command (optional).")
	flag.Parse()

	projectSource, err := os.Getwd()
	if err != nil {
		fmt.Println("Error:", err)
	}
	fmt.Printf("Your project location is %s\n", projectSource)

	// https://stackoverflow.com/a/1371283
	projectName, err := exec.Command("bash", "-c", "echo ${PWD##*/}").Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Your project name is: %s", projectName)
	}

	xdebugHost, err := exec.Command("bash", "-c", `ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`).Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("XDebug will contact your Visual Studio Code IDE at %s\n", xdebugHost)
	}

	// @TODO CHECK FOR SSH_AUTH_SOCK

	// currentEnv := os.Environ()
	// fmt.Println(currentEnv)

	sshAuthSock := os.Getenv("SSH_AUTH_SOCK")
	if sshAuthSock != "" {
		fmt.Printf("Using SSH_AUTH_SOCK: %s\n", sshAuthSock)
	} else {
		log.Default().Println("Missing environment variable: $SSH_AUTH_SOCK")
	}

	project := Project{
		composeSpecs:   "docker",
		composeOptions: string(*composeOptsPtr),
		network:        composeNetwork,
		source:         projectSource,
		name:           strings.TrimSuffix(string(projectName), "\n"),
		xdebug:         string(xdebugHost),
	}
	return project
}

func main() {
	fmt.Println("WELCOME TO THE VSD ENVIRONMENT !!!")
	fmt.Println("(V)isual Studio Code | (S)ubsystem4Linux | (D)ocker")
	fmt.Println("")

	// flagSetStatus := flag.NewFlagSet("status", flag.ExitOnError)
	// flagSetStart := flag.NewFlagSet("start", flag.ExitOnError)
	// flagSetDown := flag.NewFlagSet("down", flag.ExitOnError)
	// flagSetRec := flag.NewFlagSet("recreate", flag.ExitOnError)
	// flagSetShow := flag.NewFlagSet("show", flag.ExitOnError)

	// overrideStatus := flagSetStatus.String("override", "", "name")
	// overrideStart := flagSetStart.String("override", "", "name")
	// overrideDown := flagSetDown.String("override", "", "name")
	// overrideRec := flagSetRec.String("override", "", "name")
	// overrideShow := flagSetShow.String("override", "", "name")

	// if err := flagSetStatus.Parse(os.Args[2:]); err == nil {
	// 	fmt.Println("  name:", *overrideStatus)
	// 	fmt.Println("  tail:", flagSetStatus.Args())
	// }

	if len(os.Args) < 1 {
		showHelp()
		os.Exit(0)
	}

	project := bootstrap()
	setupNetwork(project.network)

	// Set up environment variables for Docker Compose.
	os.Setenv("COMPOSE_NETWORK", project.network)
	os.Setenv("PROJECT_SOURCE", project.source)
	os.Setenv("PROJECT_NAME", project.name)
	os.Setenv("XDEBUG_REMOTE_HOST", project.xdebug)
	os.Setenv("PROJECT_DEST", "/vsdroot")

	subcommand := flag.Arg(0)

	switch subcommand {
	case "version":
		print("VSD version 0.3.0\n")
	case "status":
		stackStatus(project)
	case "start":
		startShared(project)
		startProject(project)
		stackStatus(project)
	case "down":
		stackDown(project)
	case "recreate":
		stackDown(project)
		startShared(project)
		startProject(project)
		stackStatus(project)
	case "show":
		//@TODO: Create a mapping of services source ports, user should not need to specify them.
		serviceShow(project)
	case "open":
		servicePort := serviceShow(project)
		serviceOpen(servicePort)
	// @TODO: Provide override subcommand, emits physical compose override file from embed compose file. Provide directory listing of available overrides.
	case "log":
		serviceLog(project, fmt.Sprintf("%s", flag.Args()))
	case "drush":
		serviceDrush(project, flag.Arg(1))
	case "drush-bash":
		serviceDrushBash(project, flag.Arg(1))
	default:
		showHelp()
	}

	fmt.Println(quote.Go())
}

// ComposeExec Docker Compose command specs.
type ComposeExec struct {
	// Project name associated with Docker Compose.
	project string
	// Additional docker-compose options.
	options string
	// Embedded spec file to execute.
	spec string
	// Docker Compose command to execute.
	command string
}

// Execute Docker Compose command using embedded spec.
//
// Only one embedded file is supported by --file /dev/stdin
//
// WARNING: dockerComposeEmbed() DOES NOT provide a pty/tty response.
//
// For pipe execution see https://golang.org/pkg/os/exec/#Cmd.StdinPipe.
func dockerComposeEmbed(compose ComposeExec) {

	specFile := embedRead(compose.spec)
	cmdString := fmt.Sprintf("docker-compose --project-name %s %s --file /dev/stdin %s", compose.project, compose.options, compose.command)
	log.Default().Printf("Executing command:\n %s", cmdString)

	cmd := exec.Command("bash", "-c", cmdString)

	stdin, err := cmd.StdinPipe()
	if err != nil {
		fmt.Println("Error:", err)
	}

	go func() {
		defer stdin.Close()
		io.WriteString(stdin, string(specFile))
	}()

	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error:", err)
	}

	fmt.Printf("%s\n", out)
}

func dockerComposeTTY(compose ComposeExec) {

	cmdString := fmt.Sprintf(
		"docker-compose --project-name %s %s %s",
		compose.project,
		compose.options,
		compose.command,
	)
	log.Default().Printf("Executing command:\n %s", cmdString)

	cmd := exec.Command("bash", "-c", cmdString)
	cmd.Stdout = os.Stdout
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("Error:", err)
	}
}

// Show current stack status.
func stackStatus(project Project) {

	fmt.Println("Shared services status")
	dockerComposeEmbed(ComposeExec{
		project: "localenv",
		options: project.composeOptions,
		spec:    fmt.Sprintf("%s/docker-compose.shared.yml", project.composeSpecs),
		command: "ps",
	})

	fmt.Println("Project services status")
	dockerComposeEmbed(ComposeExec{
		project: project.name,
		options: "",
		spec:    fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.composeSpecs),
		command: "ps",
	})
}

func serviceLog(project Project, service string) {
	fmt.Println("Services log")
	dockerComposeEmbed(ComposeExec{
		project: project.name,
		options: `--file=./docker/docker-compose.shared.yml \
		--file=./docker/docker-compose.override.yml`,
		spec:    fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.composeSpecs),
		command: fmt.Sprintf("logs --follow --timestamps --tail=30 %s", service),
	})

}

// Start compose service for current directory.
func startProject(project Project) {
	fmt.Println("Start project services")
	dockerComposeEmbed(ComposeExec{
		project: project.name,
		options: "",
		spec:    fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.composeSpecs),
		command: "up --detach",
	})
}

// Fire up stack shared amongst all projects.
func startShared(project Project) {
	fmt.Println("Start shared services")
	dockerComposeEmbed(ComposeExec{
		project: "localenv",
		options: project.composeOptions,
		spec:    fmt.Sprintf("%s/docker-compose.shared.yml", project.composeSpecs),
		command: "up --detach --no-recreate",
	})
}

// Remove services, containers, and networks.
func stackDown(project Project) {
	fmt.Println("Stop shared services")
	dockerComposeEmbed(ComposeExec{
		project: "localenv",
		options: project.composeOptions,
		spec:    fmt.Sprintf("%s/docker-compose.shared.yml", project.composeSpecs),
		command: "down --remove-orphans",
	})

	fmt.Println("Stop project servicess")
	dockerComposeEmbed(ComposeExec{
		project: project.name,
		options: "",
		spec:    fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.composeSpecs),
		command: "down --remove-orphans",
	})

	run("Cleanup Docker containers",
		exec.Command("docker", "system", "prune", "--force"))

	run("Cleanup Docker network",
		exec.Command("docker", "network", "rm", project.network))
}

// Show location of service port.
//
// Example: go run ./vsd.go show nginx 8080
func serviceShow(project Project) string {
	// @TODO: Decouple domain-name for use with let's encrypt!

	var service string
	var port string

	// Define default service to show.
	var command string
	if len(os.Args) >= 3 && os.Args[2] != "" && os.Args[3] != "" {
		service = os.Args[2]
		port = os.Args[3]
	} else {
		service = "nginx"
		port = "8080"
	}

	fmt.Printf("Retrieving service %s @ %s\n", service, port)

	// NOTE: Only shows project services, and not shared services!
	command = fmt.Sprintf(`docker-compose --project-name="%s" \
	 --file %s/run/drupal/docker-compose.vsd.yml \
	 port %s %s | sed 's/0.0.0.0/%s/g'`,
		strings.TrimSuffix(project.name, "\n"),
		project.composeSpecs,
		service,
		port,
		"localhost")

	url := exec.Command("bash", "-c", command)

	srvLocation, err := url.Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Service %s is running at: %s\n", service, srvLocation)
	}
	return string(srvLocation)
}

// Open default browser to specified services' mapped port.
//
// Example: go run ./vsd.go open nginx 8080
//
// Resources:
// - https://ss64.com/nt/cmd.html
// - https://superuser.com/questions/1182275/how-to-use-start-command-in-bash-on-windows
// - https://github.com/microsoft/terminal/issues/204#issuecomment-696816617
func serviceOpen(servicePort string) {
	format := fmt.Sprintf(`cmd.exe /c start chrome "http://%s" 2> /dev/null`, servicePort)

	command := exec.Command("bash", "-c", format)
	command.Stdout = os.Stdout
	command.Stderr = os.Stdout
	if err := command.Run(); err != nil {
		fmt.Println("Error:", err)
	}
}

// Fires up drush container into current PWD.
func serviceDrush(project Project, version string) {
	fmt.Printf("Start container for drush %s\n", version)

	// Copy embedded compose specs.
	provideOverride("docker/docker-compose.shared.yml", "docker-compose.shared.yml")
	provideOverride("docker/docker-compose.override.yml", "docker-compose.override.yml")
	provideOverride("docker/run/drupal/docker-compose.vsd.yml", "docker-compose.vsd-go-drupal.yml")
	provideOverride("docker/run/drush/docker-compose.vsd.yml", "docker-compose.vsd-go-drush.yml")

	// Source specs from current PWD.
	dockerComposeTTY(ComposeExec{
		project: project.name,
		options: `--file ./docker-compose.shared.yml \
		--file ./docker-compose.override.yml \
		--file ./docker-compose.vsd-go-drupal.yml \
		--file ./docker-compose.vsd-go-drush.yml`,
		command: fmt.Sprintf("run --entrypoint=ash --rm --user=root drush%s", version),
	})
}

// TTY into Drush container using bash script.
func serviceDrushBash(project Project, version string) {
	fmt.Printf("Start container for drush %s\n", version)

	// Copy embedded compose specs.
	provideOverride("docker/docker-compose.shared.yml", "docker-compose.shared.yml")
	provideOverride("docker/docker-compose.override.yml", "docker-compose.override.yml")
	provideOverride("docker/run/drupal/docker-compose.vsd.yml", "docker-compose.vsd-go-drupal.yml")
	provideOverride("docker/run/drush/docker-compose.vsd.yml", "docker-compose.vsd-go-drush.yml")
	provideOverride("docker/scripts/vsd-go-drush7.sh", "vsd-go-drush7.sh")

	cmd := exec.Command("./vsd-go-drush7.sh")
	cmd.Stdout = os.Stdout
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("Error:", err)
	}

}
