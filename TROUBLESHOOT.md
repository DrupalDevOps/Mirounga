Restart WSL instance

https://superuser.com/a/1347725/80143


    wsl -l
    wsl.exe -t <DistroName>
    wsl.exe -t Alpine

If you need to update `/etc/hosts` on Windows:

    # Open elevated priviledge cmd.exe shell and type:
    notepad C:\Windows\System32\Drivers\etc\hosts
