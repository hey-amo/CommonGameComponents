import Testing
@testable import GameSettingsPK

@Test func testSettingsAreDisabledByDefault() async throws {
    let gameSettings = GameSettings()
    
    for setting in Setting.allCases {
        let isEnabled = await gameSettings.isEnabled(setting)
        #expect(!isEnabled)
    }
}

@Test func testToggleAndSetEnabledOneSetting() async throws {
    let settings = GameSettings()

    let soundIsEnabled = await settings.toggle(.sound)
    #expect(soundIsEnabled)
    var currentSoundSetting = await settings.isEnabled(.sound)
    var currentMusicSetting = await settings.isEnabled(.music)
    #expect(currentSoundSetting)
    #expect(!currentMusicSetting)
    
    await settings.setEnabled(true, for: .music)
    await settings.setEnabled(true, for: .music)
    currentMusicSetting = await settings.isEnabled(.music)
    #expect(currentMusicSetting)

    let soundIsStillEnabled = await settings.toggle(.sound)
    #expect(!soundIsStillEnabled)
    
    currentSoundSetting = await settings.isEnabled(.sound)
    #expect(!currentSoundSetting)
}

@Test func testPreferencesReflectCurrentInMemoryState() async throws {
    let settings = GameSettings(enabledSettings: [.sound, .darkMode])

    let preferences = await settings.preferences

    #expect(
        preferences == [
            .sound(enabled: true),
            .music(enabled: false),
            .haptic(enabled: false),
            .darkMode(enabled: true)
        ]
    )
    
}

@Test func testConcurrentTogglesAreSerialized() async throws {
    let settings = GameSettings()

    try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<500 {
            group.addTask {
                await settings.toggle(.sound)
            }
        }
        try await group.waitForAll()
    }

    let isEnabled = await settings.isEnabled(.sound)
    //XCTAssertFalse(isEnabled)
    #expect(!isEnabled)
}


