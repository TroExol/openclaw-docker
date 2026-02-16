# ==============================================================================
# Создаёт задачу в Windows Task Scheduler для ежедневного бэкапа OpenClaw
# Запускать один раз от имени администратора:
#   powershell -ExecutionPolicy Bypass -File setup-backup-task.ps1
# ==============================================================================

$TaskName = "OpenClaw Daily Backup"
$ScriptPath = "D:\Programs\openclaw\backup.sh"
$LogFile = "D:\Programs\openclaw\backups\backup.log"
$TriggerTime = "03:00"

# Удаляем старую задачу если есть
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

$Action = New-ScheduledTaskAction `
    -Execute "bash" `
    -Argument "-c `"$ScriptPath >> $LogFile 2>&1`""

$Trigger = New-ScheduledTaskTrigger -Daily -At $TriggerTime

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Principal $Principal `
    -Description "Ежедневный бэкап данных OpenClaw (config + workspace) в 03:00"

Write-Host ""
Write-Host "Задача '$TaskName' создана." -ForegroundColor Green
Write-Host "Бэкап будет запускаться каждый день в $TriggerTime"
Write-Host "Логи: $LogFile"
Write-Host ""
Write-Host "Проверить: Get-ScheduledTask -TaskName '$TaskName'"
Write-Host "Удалить:   Unregister-ScheduledTask -TaskName '$TaskName'"
