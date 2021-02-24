package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"regexp"

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
func setup_network(compose_network string) {
	networks := exec.Command("docker", "network", "ls")
	output, nil := networks.Output()

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

func help() {
	fmt.Println("Help placeholder")
}

// Environment variables used by Docker Compose.
type Project struct {
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
	COMPOSE_NETWORK := `VSD`

	PROJECT_SOURCE, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	fmt.Printf("Your project location is %s\n", PROJECT_SOURCE)

	PROJECT_NAME, err := exec.Command("bash", "-c", "echo ${PWD##*/}").Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("Your project name is: %s", PROJECT_NAME)
	}

	XDEBUG_HOST, err := exec.Command("bash", "-c", `ip addr show eth0 | grep -oE '\d+(\.\d+){3}' | head -n 1`).Output()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Printf("XDebug will contact your Visual Studio Code IDE at %s\n", XDEBUG_HOST)
	}

	return Project{COMPOSE_NETWORK, PROJECT_SOURCE, string(PROJECT_NAME), string(XDEBUG_HOST)}
}

func main() {
	fmt.Println("WELCOME TO THE VSD ENVIRONMENT !!!")
	fmt.Println("(V)isual Studio Code | (S)ubsystem4Linux | (D)ocker")
	fmt.Println("")

	if len(os.Args) == 1 {
		help()
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
		fmt.Println("get status")
	case "start":
		fmt.Println("starting")
		start_shared()
	case "stop":
		fmt.Println("stopping")
	case "recreate":
	case "rec":
		fmt.Println("recreating")
	}

	fmt.Println(quote.Go())
}

// Create compose stack for current directory.
func project_stack() {

}

// Fire up stack shared amongst all projects.
func start_shared() {
	stack_location := "../.."
	shared := exec.Command("docker-compose",
		"--file", fmt.Sprintf("%s/docker-compose.shared.yml", stack_location),
		"--file", fmt.Sprintf("%s/docker-compose.override.yml", stack_location),
		"up", "--detach", "--no-recreate")
	run("start shared stack", shared)
}
