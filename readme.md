
# Windows "php artisan" Alias Creator For Laravel

This PowerShell script allows you to create a convenient alias for the `php artisan` command on Windows. The script automates the process of creating a batch file for the alias, adding the directory to the system PATH, and ensuring there are no conflicts with existing aliases. Additionally, it handles the cleanup of empty directories and their removal from the PATH if necessary.

## Features

- Creates a batch file alias for the `php artisan` command.
- Adds the alias directory to the system PATH.
- Checks for conflicts with existing aliases and handles them appropriately.
- While creating an alias, if a php artisan alias already exists, it can clean up the old php artisan alias and delete its directory along with the PATH entry if there are no other files in the directory.

## Prerequisites

- Windows operating system.
- Administrator privileges to modify the system PATH.

## Usage

### Direct Download and Execute Script from CMD

1. **Open Command Prompt:**
    - Press `Win + R`, type `cmd`, and press `Enter`.

2. **Download the PowerShell script using the following command:**
    ```cmd
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/Skysea45/windows-artisan-alias/main/windows-artisan-alias.ps1 -OutFile %TEMP%\windows-artisan-alias.ps1"
    ```

3. **Run the downloaded PowerShell script with admin privileges using the following command:**
    ```cmd
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%TEMP%\windows-artisan-alias.ps1"' -Verb RunAs}"
    ```


2. **Starting the Script:**
    - When the script starts, it will check for administrator privileges. If not running as an administrator, it will prompt for the necessary permissions.

3. **Options Menu:**
    - The script will present you with two options:
        1. Start the process.
        2. Exit.
    - Select `1` to proceed with creating the alias or `2` to exit the script.

4. **Directory Selection:**
    - The default directory for storing the alias batch file is `C:\aliases` (it automatically detects your system disk even its not labeled as C ).
    - You will be asked if you want to change the default directory. Press `n` to keep the default or `y` to specify a custom directory.

5. **Alias Name Selection:**
    - The default alias name is `pia`.
    - You will be asked if you want to change the default alias name. Press `n` to keep the default or `y` to specify a custom alias name.

6. **Conflict Check and Removal:**
    - The script will check if there is any existing `php artisan` alias in the system PATH.
    - If a conflict is found, you will be prompted to remove the existing alias and use the new one. Press `y` to proceed with the removal or `n` to cancel the alias creation process.

7. **Alias Creation:**
    - The script will create the alias batch file in the specified directory.
    - If the directory does not exist, it will be created.
    - The directory will be added to the system PATH if not already present.

8. **Cleanup:**
    - If an alias is removed and the directory becomes empty, the directory and its PATH entry will also be removed to keep the system clean.

9. **Completion:**
    - A message will be displayed indicating that the alias was successfully created and added to the PATH.
    - The script will close automatically after a brief pause.

## Security

To ensure the integrity of the script, you can verify the SHA-256 hash of the downloaded script file. The SHA-256 hash for this script is:


```
SHA-256: DC1C631BEA24CA0F2D7F0B74C537DF420758ECCCFCA78530E72DB1AA36A7A640
```

To verify the hash on your system, run the following PowerShell command:

```powershell
Get-FileHash windows-artisan-alias.ps1 -Algorithm SHA256 | Format-List 
```

Replace `windows-artisan-alias.ps1` with the actual path where you saved the script.

**Note: I have prepared this script based on my own testing and use cases. However, I am not responsible for any issues or damages that may arise from using this script.**
##

## Contributing

Feel free to contribute to this project by submitting issues or pull requests on GitHub. Your feedback and contributions are greatly appreciated!

## License

This project is licensed under the MIT License.
