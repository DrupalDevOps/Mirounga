package main

import (
	"embed"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"rsc.io/quote"
)

//go:embed hello.txt
var s string

//go:embed docker
var dockerfs embed.FS

func test_assets() {
	print(s)
	// func (f FS) Open(name string) (fs.File, error)
	file, e := dockerfs.ReadFile("docker/docker-compose.yml")
	if e != nil {
		panic(e)
	} else {
		print(string(file))
	}

	// d1 := []byte("hello\ngo\n")
	err := ioutil.WriteFile("/tmp/dat1", file, 0644)
	if err != nil {
		panic(err)
	}
}

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
func setup_network(compose_network string) {
	networks := exec.Command("docker", "network", "ls")
	output, err := networks.Output()
	if err != nil {
		log.Println(err)
	}

	matches := regexp.MustCompile(compose_network).FindStringSubmatch(string(output))
	if len(matches) >= 1 {
		fmt.Printf("Docker network %s already exists, joining.\n", compose_network)
	} else {
		fmt.Println("Create user-defined network")
		create_newnet := exec.Command("docker", "network", "create", "--driver", "bridge", "--attachable", compose_network)
		if output, err := create_newnet.Output(); err != nil {
			fmt.Println("Error:", err)
		} else {
			fmt.Printf("Otuput: %s\n", output)
		}
	}
}

func show_help() {
	fmt.Println("Help placeholder")
}

// Environment variables used by Docker Compose.
type Project struct {
	// Path to Docker Compose specifications.
	compose_specs string
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

// Gather information used by all sub-commands.
func gather_prerequisites() Project {
	compose_network := `VSD`

	project_source, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	fmt.Printf("Your project location is %s\n", project_source)

	// https://stackoverflow.com/a/1371283
	project_name, err := exec.Command("bash", "-c", "echo ${PWD##*/}").Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Your project name is: %s", project_name)
	}

	xdebug_host, err := exec.Command("bash", "-c", `ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`).Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("XDebug will contact your Visual Studio Code IDE at %s\n", xdebug_host)
	}

	return Project{"./docker", compose_network, project_source, string(project_name), string(xdebug_host)}
}

func main() {
	fmt.Println("WELCOME TO THE VSD ENVIRONMENT !!!")
	fmt.Println("(V)isual Studio Code | (S)ubsystem4Linux | (D)ocker")
	fmt.Println("")

	test_assets()

	if len(os.Args) == 1 {
		show_help()
		os.Exit(0)
	}

	project := gather_prerequisites()
	setup_network(project.network)

	// Set up environment variables for Docker Compose.
	os.Setenv("COMPOSE_NETWORK", project.network)
	os.Setenv("PROJECT_SOURCE", project.source)
	os.Setenv("PROJECT_NAME", project.name)
	os.Setenv("XDEBUG_REMOTE_HOST", project.xdebug)

	switch os.Args[1] {
	case "status":
		stack_status(project)
	case "start":
		start_shared(project)
		start_project(project)
		stack_status(project)
	case "down":
		stack_down(project)
	case "recreate":
	case "rec":
		stack_down(project)
		start_shared(project)
		start_project(project)
		stack_status(project)
	case "show":
		//@TODO: Create a mapping of services source ports, user should not need to specify them.
		service_show(project)
	case "open":
		service_port := service_show(project)
		service_open(service_port)
	default:
		show_help()
	}

	fmt.Println(quote.Go())
}

// Show current stack status.
func stack_status(project Project) {
	run("Shared stack status",
		exec.Command("docker-compose",
			"--file", fmt.Sprintf("%s/docker-compose.shared.yml", project.compose_specs),
			"--file", fmt.Sprintf("%s/docker-compose.override.yml", project.compose_specs),
			"ps"))
	run("Project stack status",
		exec.Command("docker-compose",
			"--project-name", project.name,
			"--file", fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.compose_specs),
			"ps"))
}

// Create compose stack for current directory.
func start_project(project Project) {
	run("Start project stack",
		exec.Command("docker-compose",
			"--project-name", project.name,
			"--file", fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.compose_specs),
			"up", "--detach"))
}

// Fire up stack shared amongst all projects.
func start_shared(project Project) {
	run("Start shared stack",
		exec.Command("docker-compose",
			"--file", fmt.Sprintf("%s/docker-compose.shared.yml", project.compose_specs),
			"--file", fmt.Sprintf("%s/docker-compose.override.yml", project.compose_specs),
			"up", "--detach", "--no-recreate"))
}

// Remove services, containers, and networks.
func stack_down(project Project) {
	run("Stop shared services",
		exec.Command("docker-compose",
			"--file", fmt.Sprintf("%s/docker-compose.shared.yml", project.compose_specs),
			"down", "--remove-orphans"))
	// "down", "--volumes", "--remove-orphans"))

	run("Stop project services",
		exec.Command("docker-compose",
			"--project-name", project.name,
			"--file", fmt.Sprintf("%s/run/drupal/docker-compose.vsd.yml", project.compose_specs),
			"down"))

	run("Cleanup Docker containers",
		exec.Command("docker", "system", "prune", "--force"))

	run("Cleanup Docker network",
		exec.Command("docker", "network", "rm", project.network))
}

// Show location of service port.
//
// Example: go run ./vsd.go show nginx 8080
func service_show(project Project) string {
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
		project.compose_specs,
		service,
		port,
		"localhost")

	url := exec.Command("bash", "-c", command)

	service_location, err := url.Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Service %s is running at: %s\n", service, service_location)
	}
	return string(service_location)
}

// Open default browser to specified services' mapped port.
//
// Example: go run ./vsd.go open nginx 8080
//
// Resources:
// - https://ss64.com/nt/cmd.html
// - https://superuser.com/questions/1182275/how-to-use-start-command-in-bash-on-windows
// - https://github.com/microsoft/terminal/issues/204#issuecomment-696816617
func service_open(service_port string) {
	format := fmt.Sprintf(`cmd.exe /c start chrome "http://%s" 2> /dev/null`, service_port)

	command := exec.Command("bash", "-c", format)
	command.Stdout = os.Stdout
	command.Stderr = os.Stdout
	if err := command.Run(); err != nil {
		fmt.Println("Error:", err)
	}
}
