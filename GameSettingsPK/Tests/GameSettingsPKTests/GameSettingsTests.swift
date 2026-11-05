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
    let settings = GameSettings(enabledSettings: [.sound, .darkMode, .showHints])

    let preferences = await settings.preferences

    #expect(
        preferences == [
            .sound(enabled: true),
            .music(enabled: false),
            .haptic(enabled: false),
            .darkMode(enabled: true),
            .showHints(enabled: true)
        ]
    )
    
}

@Test func testPreferencePropertiesReflectTheirValues() {
    let preferences: [(Preference, Setting, Bool)] = [
        (.sound(enabled: true), .sound, true),
        (.music(enabled: false), .music, false),
        (.haptic(enabled: true), .haptic, true),
        (.darkMode(enabled: false), .darkMode, false),
        (.showHints(enabled: true), .showHints, true)
    ]

    for (preference, setting, isEnabled) in preferences {
        #expect(preference.setting == setting)
        #expect(preference.isEnabled == isEnabled)
    }
}

@Test func testSetEnabledFalseDisablesSetting() async throws {
    let settings = GameSettings(enabledSettings: [.sound])

    await settings.setEnabled(false, for: .sound)

    #expect(!(await settings.isEnabled(.sound)))
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
