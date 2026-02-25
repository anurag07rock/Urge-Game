import Foundation

enum GameType: String, Codable, CaseIterable, Identifiable {
    case breathing
    case stressSmash
    case focusSniper
    case rhythmPulse
    case memoryPuzzle
    case grounding
    case focusHold
    case volcanoVent
    case bubblePopBlitz
    case connectionConstellation
    case patternBreak
    // Wave 2
    case waveRider
    case thunderJar
    case iceSculptor
    case moodMixer
    case rootAndGrow
    case mirrorMind
    case unravel
    case summitClimb
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .breathing: return "Breathing"
        case .stressSmash: return "Stress Smash"
        case .focusSniper: return "Focus Sniper"
        case .rhythmPulse: return "Rhythm Pulse"
        case .memoryPuzzle: return "Brain Flip"
        case .grounding: return "Grounding"
        case .focusHold: return "Freeze Challenge"
        case .volcanoVent: return "Volcano Vent"
        case .bubblePopBlitz: return "Bubble Pop Blitz"
        case .connectionConstellation: return "Connection Constellation"
        case .patternBreak: return "Pattern Break"
        case .waveRider: return "Wave Rider"
        case .thunderJar: return "Thunder Jar"
        case .iceSculptor: return "Ice Sculptor"
        case .moodMixer: return "Mood Mixer"
        case .rootAndGrow: return "Root & Grow"
        case .mirrorMind: return "Mirror Mind"
        case .unravel: return "Unravel"
        case .summitClimb: return "Summit Climb"
        }
    }
    
    var description: String {
        switch self {
        case .breathing: return "Calm your mind with guided breathing."
        case .stressSmash: return "Break objects to release tension."
        case .focusSniper: return "Tap correct targets to sharpen focus."
        case .rhythmPulse: return "Tap in sync with calming beats."
        case .memoryPuzzle: return "Challenge your memory with cards."
        case .grounding: return "Reconnect with your senses."
        case .focusHold: return "Hold steady to build resistance."
        case .volcanoVent: return "Release the pressure before it erupts."
        case .bubblePopBlitz: return "Pop your way out of the empty feeling."
        case .connectionConstellation: return "Connect stars to reveal messages of belonging."
        case .patternBreak: return "Break the loop before it breaks you."
        case .waveRider: return "Ride the waves with your breath."
        case .thunderJar: return "Shake to shatter the tension inside."
        case .iceSculptor: return "Carve a hidden shape from ice."
        case .moodMixer: return "Blend emotions to find your signature."
        case .rootAndGrow: return "Grow a tree that remembers your journey."
        case .mirrorMind: return "Mirror the light in calm stillness."
        case .unravel: return "Slowly untangle the yarn to break free."
        case .summitClimb: return "Hold steady as your climber ascends."
        }
    }
    
    var instructionSteps: [String] {
        switch self {
        case .breathing:
            return ["Follow the circle as it expands.", "Inhale as it grows.", "Exhale as it shrinks.", "Stay with your breath until time ends."]
        case .stressSmash:
            return ["Tap the objects to break them.", "Release your tension with every smash.", "Keep smashing until time runs out."]
        case .focusSniper:
            return ["Moving targets will appear.", "Tap only the correct ones.", "Avoid the traps.", "Maintain focus for 30 seconds."]
        case .rhythmPulse:
            return ["Listen to the calming rhythm.", "Tap the pulse when it hits the center.", "Stay in sync to build a calm streak.", "Find your flow."]
        case .memoryPuzzle:
            return ["Watch the cards carefully.", "Find the matching pairs.", "Clear the board before time runs out."]
        case .focusHold:
            return ["Press and hold the circle.", "Do not lift your finger.", "If you release, progress is reduced.", "Hold steady until time ends."]
        case .grounding:
            return ["Read the prompt.", "Reflect briefly.", "Tap confirm.", "Move through all grounding steps."]
        case .volcanoVent:
            return ["Hold anywhere on screen to build pressure.", "Watch the ring fill as tension builds.", "Release to trigger a satisfying eruption.", "Complete 3 eruptions to finish."]
        case .bubblePopBlitz:
            return ["Colourful bubbles will float upward.", "Pop the GOLD bubbles for points.", "Let the grey craving bubbles float away.", "Stay sharp for 30 seconds!"]
        case .connectionConstellation:
            return ["Tap a star to select it.", "Drag to connect it to another star.", "Each connection reveals an affirming message.", "Connect all stars to complete the constellation."]
        case .patternBreak:
            return ["Four items appear in a grid.", "Three follow a pattern, one breaks it.", "Tap the odd one out.", "Answer fast for a speed bonus!"]
        case .waveRider:
            return ["Swipe up and down to ride the waves.", "Match the breathing ring rhythm.", "Complete 3 perfect breath-ride cycles.", "Let the ocean calm you."]
        case .thunderJar:
            return ["See the glowing electric jar.", "Shake your phone to crack it.", "Watch it shatter with a blast.", "Feel the tension leave your body."]
        case .iceSculptor:
            return ["An ice block hides a shape inside.", "Drag your finger to chip away the ice.", "Reveal the hidden form completely.", "Watch it float free!"]
        case .moodMixer:
            return ["Three emotion orbs float on screen.", "Drag them together to blend.", "Colors and feelings mix like ink.", "Discover your emotional signature."]
        case .rootAndGrow:
            return ["Start with a tiny seed.", "Tap to grow roots downward.", "Tap more to grow branches upward.", "Your tree saves and grows across sessions."]
        case .mirrorMind:
            return ["Watch the glowing quadrants light up.", "Mirror the sequence back calmly.", "No timer. No fail state.", "Just be present with the light."]
        case .unravel:
            return ["See the tangled yarn ball.", "Drag the glowing thread slowly around it.", "Each clean loop peels a layer.", "5 layers = freedom."]
        case .summitClimb:
            return ["Hold your phone still.", "A climber ascends the mountain.", "Tilting makes the climber slip.", "Steady hands reach the summit."]
        }
    }
    
    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .stressSmash: return "hammer.fill"
        case .focusSniper: return "target"
        case .rhythmPulse: return "waveform.path"
        case .memoryPuzzle: return "square.grid.2x2"
        case .grounding: return "leaf.fill"
        case .focusHold: return "hand.raised.fill"
        case .volcanoVent: return "flame.fill"
        case .bubblePopBlitz: return "bubbles.and.sparkles.fill"
        case .connectionConstellation: return "sparkles"
        case .patternBreak: return "square.grid.2x2.fill"
        case .waveRider: return "water.waves"
        case .thunderJar: return "bolt.fill"
        case .iceSculptor: return "snowflake"
        case .moodMixer: return "theatermasks.fill"
        case .rootAndGrow: return "tree.fill"
        case .mirrorMind: return "circle.grid.2x2.fill"
        case .unravel: return "lasso"
        case .summitClimb: return "mountain.2.fill"
        }
    }
}
