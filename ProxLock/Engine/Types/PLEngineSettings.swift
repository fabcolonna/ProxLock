struct PLEngineSettings {
    var wakeThresholdEnabled = false
    var lockToScreenSaver    = false
    var pauseNowPlaying      = false
    var launchOnLogin        = false
    var delayBeforeLocking   = false
    var noSignalTimeout      = false
    
    var lockThreshold: DBm
    var wakeThreshold: DBm
}
