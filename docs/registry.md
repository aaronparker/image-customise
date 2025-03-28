# Registry Settings

## Machine-Windows11.All.json

Minimum build: 10.0.22000

Maximum build: 10.0.29999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \Software \Microsoft \Windows \CurrentVersion \Communications | ConfigureChatAutoInstall | 0 | Prevents the install of the consumer Microsoft Teams client |

## Machine.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \Explorer | DisableEdgeDesktopShortcutCreation | 1 | Prevents the Microsoft Edge short added to the public desktop |
| HKLM: \SOFTWARE \Microsoft \Windows NT \CurrentVersion \FontSubstitutes | MS Shell Dlg | Tahoma | Replaces the `MS Shell Dlg` font with `Tahoma` for UI consistency |
| HKLM: \SOFTWARE \Microsoft \Windows NT \CurrentVersion \FontSubstitutes | MS Shell Dlg 2 | Tahoma | Replaces the `MS Shell Dlg 2` font with `Tahoma` for UI consistency |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \CapabilityAccessManager \ConsentStore \location | Value | Allow | Enables location services |
| HKLM: \SOFTWARE \Policies \Microsoft \Edge | SearchbarAllowed | 0 | Prevent the Microsoft Edge search bar from being added to the desktop |
| HKLM: \SOFTWARE \Policies \Microsoft \EdgeUpdate | CreateDesktopShortcutDefault | 0 | Prevent the Microsoft Edge shortcut from being added to the desktop |
| HKLM: \SOFTWARE \Policies \Microsoft \EdgeUpdate | RemoveDesktopShortcutDefault | 1 | Prevent the Microsoft Edge shortcut from being added to the desktop |

## Machine.Client.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \Software \Microsoft \Windows \CurrentVersion \Explorer | DisableEdgeDesktopShortcutCreation | 1 | Prevents the Microsoft Edge short added to the public desktop |
| HKLM: \Software \Policies \Microsoft \Windows \CloudContent | DisableWindowsConsumerFeatures | 1 | Disables the Microsoft Windows consumer features |
| HKLM: \Software \Policies \Microsoft \Windows \CloudContent | DisableCloudOptimizedContent | 1 | Disables the customisation of the taskbar with additional shortcuts (e.g. new Outlook) |


Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | note |
| ---- | ---- |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \WindowsUpdate \Orchestrator \UScheduler_Oobe \DevHomeUpdate | Removes the Dev Home app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \WindowsUpdate \Orchestrator \UScheduler \DevHomeUpdate | Removes the Dev Home app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \WindowsUpdate \Orchestrator \UScheduler_Oobe \DevHomeUpdate | Removes the Dev Home app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \WindowsUpdate \Orchestrator \UScheduler_Oobe \OutlookUpdate | Removes the Outlook (new) app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \WindowsUpdate \Orchestrator \UScheduler \OutlookUpdate | Removes the Outlook (new) app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \WindowsUpdate \Orchestrator \UScheduler_Oobe \OutlookUpdate | Removes the Outlook (new) app from the Windows Update Orchestrator to prevent automatic install on Windows 11 |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \WindowsUpdate \Orchestrator \UScheduler \MS_Outlook | Removes the Outlook (new) app from the Windows Update Orchestrator to prevent automatic install on Windows 10 |

## Services.Client.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \SYSTEM \CurrentControlSet \Services \tzautoupdate | Start | 3 | Enable Set time zone automatically |

## User-Windows10.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.20999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Accent | AccentColor | 4289992518 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Accent | AccentPalette | 86CAFF005FB2F2001E91EA000063B10000427500002D4F000020380000CC6A00 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | AccentColor | 4289815296 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | ColorizationAfterglow | 3288359857 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | ColorizationColor | 3288359857 | Sets the accent colour on window title bars and borders |

## User-Windows11.All.json

Minimum build: 10.0.22000

Maximum build: 10.0.29999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarMn | 0 | Remove the Chat icon from the Taskbar - note: this value should not be needed on Windows 11 23H2 or higher |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarDa | 0 | Remove the Widgets icon from the Taskbar - note: this value is protected by permissions |

## User.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows NT \CurrentVersion \Network \Persistent Connections | SaveConnections | No | Prevents persistent mapped drives in Explorer. Assumes scripts or GPP are used to map network drives |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \AdvertisingInfo | Enabled | 0 | Turns off the feature that lets apps use the advertising ID |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \AppHost | EnableWebContentEvaluation | 1 | Turns on Smart Screen for apps |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SystemPaneSuggestionsEnabled | 0 | Disables app suggestions in the Start menu |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SilentInstalledAppsEnabled | 0 | Disables app suggestions in the Start menu |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Search | BingSearchEnabled | 0 | Disables web search in the Start menu for better responsiveness |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | LaunchTo | 1 | Configures File Explorer to start on This PC |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | HideFileExt | 0 | Enables the display of file extensions in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | SeparateProcess | 1 | Runs File Explorer windows in different processes so that one window crash won't affect all windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarGlomLevel | 1 | Configures Taskbar buttons on the primary monitor to combine when the Taskbar is full |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | MMTaskbarGlomLevel | 1 | Configures Taskbar buttons on secondary monitors to combine when the Taskbar is full |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | Start_IrisRecommendations | 0 | Remove 'Recommendations for tips, shortcuts, new apps, and more' in the Start menu |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced \People | PeopleBand | 0 | Removes the People icon from the Taskbar on Windows 10 |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \UserProfileEngagement | ScoobeSystemSettingEnabled | 0 | Disable 'Suggest ways to get the most out of Windows and finish setting up this device' Screen in Settings / System / Notifications |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Search | SearchboxTaskbarMode | 3 | Collapses the Search box into an icon on the Taskbar |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Search | SearchboxTaskbarModeCache | 3 | Required to support the setting selected for SearchboxTaskbarMode |
| HKCU: \SOFTWARE \Microsoft \Windows \CurrentVersion \CapabilityAccessManager \ConsentStore \location \NonPackaged | Value | Allow | Enables location services for Win32 applications |
| HKCU: \SOFTWARE \Microsoft \Windows \CurrentVersion \CapabilityAccessManager \ConsentStore \location | Value | Allow | Enables location services for Universal Windows Platform Apps |
| HKCU: \Control Panel \Accessibility | MessageDuration | 30 | Increase the timeout for new notifications - Dismiss notifications after this amount of time |
| HKCU: \Software \Adobe \Acrobat Reader \DC \AVAlert \cCheckbox | iAppDoNotTakePDFOwnershipAtLaunchWin10 | 1 | Prevents the default file type dialog box at Adobe Acrobat Reader DC first launch |
| HKCU: \Software \Adobe \Adobe Acrobat \DC \AVAlert \cCheckbox | iAppDoNotTakePDFOwnershipAtLaunchWin10 | 1 | Prevents the default file type dialog box at Adobe Acrobat Pro/Standard DC first launch |
| HKCU: \Software \Microsoft \Windows \DWM | ColorPrevalence | 1 | Enables 'Show accent colour on title bars and window borders' |

## User.Client.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Wallpapers | BackgroundType | 0 | Sets the desktop background type to a picture |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \DesktopSpotlight \Settings | EnabledState | 0 | Disables Windows spotlight |
| HKCU: \Console \%%Startup | DelegationConsole | {2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69} | Sets Windows Terminal as the default terminal |
| HKCU: \Console \%%Startup | DelegationTerminal | {E12CFF52-A866-4C77-9A90-F570A7AA2C6B} | Sets Windows Terminal as the default terminal |

## User.Server.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \ServerManager | DoNotOpenServerManagerAtLogon | 1 | Prevents Server Manager from starting at login |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableBlurBehind | 1 | Disable blur for the Start menu, Taskbar and windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Search | SearchboxTaskbarMode | 0 | Hides the Search icon on the Taskbar |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ShowTaskViewButton | 0 | Removes the Task View button on the Taskbar |

## User.Virtual.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableBlurBehind | 0 | Disable blur for the Start menu, Taskbar and windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableTransparency | 0 | Disable transparency for the Start menu, Taskbar and windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | IconsOnly | 1 | Show icons only and not document previews |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ListviewAlphaSelect | 0 | Disables the translucent selection rectangle in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ListviewShadow | 0 | Disables drop shadows on icons in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ShowCompColor | 1 | Changes the font colour for compressed NTFS files / directories |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ShowInfoTip | 1 | Disables tooltips in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarAnimations | 0 | Disables animations in the Taskbar |
| HKCU: \Software \Microsoft \Windows \DWM | EnableAeroPeek | 0 | Disables Peek at desktop and Taskbar thumbnail live previews |
| HKCU: \Software \Microsoft \Windows \DWM | AlwaysHibernateThumbnails | 0 | Disables Taskbar preview thumbnail cache |
| HKCU: \Control Panel \Desktop | DragFullWindows | 1 | Disables the display of the window contents when dragging |
| HKCU: \Control Panel \Desktop \WindowMetrics | MinAnimate | 0 | Disables animations for minimise and maximise actions for windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338393Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-353694Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-353696Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338388Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338389Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-310093Enabled | 0 | Disables 'Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what's new and suggested' |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.Windows.Photos_8wekyb3d8bbwe | Disabled | 1 | Prevents the Photos app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.Windows.Photos_8wekyb3d8bbwe | DisabledByUser | 1 | Prevents the Photos app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.YourPhone_8wekyb3d8bbwe | Disabled | 1 | Prevents the Your Phone app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.YourPhone_8wekyb3d8bbwe | DisabledByUser | 1 | Prevents the Your Phone app from running in the background |
