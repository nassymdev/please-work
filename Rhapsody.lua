--- STEAMODDED HEADER
--- MOD_NAME: Rhapsody
--- MOD_ID: Rhapsody
--- MOD_AUTHOR: [YourName]
--- MOD_DESCRIPTION: A comprehensive music manager for Balatro
--- BADGE_COLOUR: E91E63
--- PREFIX: rhap
--- VERSION: 1.0.0

----------------------------------------------
------------MOD CODE -------------------------

-- Initialize Rhapsody namespace
Rhapsody = {}

-- Load core modules
local core_modules = {
    "core/config",
    "core/storage", 
    "core/audio",
    "core/api",
    "ui/state",
    "ui/components",
    "ui/screens",
    "ui/main",
    "integration/hooks"
}

-- Load each module
for _, module in ipairs(core_modules) do
    local module_path = SMODS.current_mod.path .. module .. ".lua"
    local success, err = pcall(function()
        assert(SMODS.load_file(module_path))()
    end)
    
    if not success then
        print("Rhapsody: Failed to load module " .. module .. ": " .. tostring(err))
    else
        print("Rhapsody: Loaded module " .. module)
    end
end

-- Main initialization function
function Rhapsody.init()
    print("Rhapsody: Starting initialization...")
    
    -- Load configuration
    if Rhapsody.load_config then
        Rhapsody.load_config()
    end
    
    -- Initialize custom music scanning
    if Rhapsody.init_custom_music then
        Rhapsody.init_custom_music()
    end
    
    -- Set up game integration hooks
    if Rhapsody.init_all_hooks then
        Rhapsody.init_all_hooks()
    end
    
    -- Initialize UI system
    if Rhapsody.init_ui then
        Rhapsody.init_ui()
    end
    
    -- Set up context-aware music
    if Rhapsody.init_context_music then
        Rhapsody.init_context_music()
    end
    
    -- Add example tracks for testing (remove in production)
    Rhapsody.init_example_content()
    
    print("Rhapsody: Initialization complete!")
    print("Rhapsody: Press F9 to open the music manager")
    print("Rhapsody: Loaded " .. Rhapsody.get_track_count() .. " tracks in " .. Rhapsody.get_playlist_count() .. " playlists")
end

-- Add example content for demonstration
function Rhapsody.init_example_content()
    -- Example tracks with joker associations
    Rhapsody.track{
        Key = "joker_theme",
        Name = "Wild Card Symphony", 
        Author = "Rhapsody Composer",
        Text = {"A playful melody that dances", "like a wild joker in the wind"},
        Path = "music/joker_theme.mp3",
        Joker = "j_joker"
    }
    
    Rhapsody.track{
        Key = "menu_ambient",
        Name = "Dealer's Lounge",
        Author = "Casino Orchestra", 
        Text = {"Smooth jazz for the sophisticated", "card player's evening"},
        Path = "music/menu_ambient.ogg",
        Joker = nil
    }
    
    Rhapsody.track{
        Key = "victory_fanfare",
        Name = "Royal Flush Victory",
        Author = "Triumph Ensemble",
        Text = {"Triumphant horns celebrate", "your masterful hand"},
        Path = "music/victory.wav",
        Joker = "j_steel_joker"
    }
    
    Rhapsody.track{
        Key = "suspense_build",
        Name = "All In Tension",
        Author = "High Stakes Collective",
        Text = {"Building tension as the", "stakes reach their peak"},
        Path = "music/suspense.mp3",
        Joker = "j_scary_face"
    }
    
    -- Example playlists
    Rhapsody.playlist{
        Key = "casino_classics",
        Name = "Casino Classics",
        Tracks = {"menu_ambient", "joker_theme", "victory_fanfare"}
    }
    
    Rhapsody.playlist{
        Key = "dramatic_moments", 
        Name = "Dramatic Moments",
        Tracks = {"suspense_build", "victory_fanfare"}
    }
    
    Rhapsody.playlist{
        Key = "joker_themes",
        Name = "Joker Collection", 
        Tracks = {"joker_theme", "victory_fanfare", "suspense_build"}
    }
    
    print("Rhapsody: Example content loaded")
end

-- Global update function for mod integration
function Rhapsody.update_all(dt)
    if Rhapsody.config.ui_open and Rhapsody.ui.update then
        Rhapsody.ui.update(dt)
    end
    
    if Rhapsody.update_audio then
        Rhapsody.update_audio(dt)
    end
end

-- API Documentation for other mod developers
--[[
RHAPSODY MOD API DOCUMENTATION
==============================

Basic Usage:
-----------

To add a track to Rhapsody from your mod:

Rhapsody.track{
    Key = "unique_track_id",           -- Required: Unique identifier
    Name = "Track Display Name",       -- Required: Display name
    Author = "Artist Name",           -- Optional: Artist/composer name
    Text = {"Line 1", "Line 2"},     -- Optional: Description lines
    Path = "music/filename.mp3",     -- Required: Path to audio file
    Joker = "j_joker_key"           -- Optional: Associated joker key
}

To add a playlist:

Rhapsody.playlist{
    Key = "unique_playlist_id",        -- Required: Unique identifier  
    Name = "Playlist Display Name",    -- Required: Display name
    Tracks = {"track1", "track2"}     -- Required: Array of track keys
}

Advanced Features:
-----------------

- Tracks with associated jokers will display music info in joker tooltips
- Custom music folder scanning for user-imported tracks
- Context-aware music playback based on game state
- Animated UI with particle effects and smooth transitions
- Audio visualization and progress tracking
- Playlist management and navigation

Integration Examples:
--------------------

-- Add boss-specific music
Rhapsody.track{
    Key = "boss_fight_music",
    Name = "Final Confrontation", 
    Author = "Epic Orchestral",
    Text = {"Intense battle music for", "the ultimate showdown"},
    Path = "music/boss_theme.ogg"
}

-- Create themed playlist
Rhapsody.playlist{
    Key = "boss_collection",
    Name = "Boss Battle Themes",
    Tracks = {"boss_fight_music", "victory_fanfare"}
}

-- Associate music with custom joker
Rhapsody.track{
    Key = "my_joker_theme",
    Name = "Custom Joker Song",
    Author = "My Mod Music",
    Path = "music/my_joker.mp3", 
    Joker = "my_custom_joker_key"  -- Your joker's key
}

File Format Support:
-------------------
- MP3 (.mp3)
- WAV (.wav) 
- OGG Vorbis (.ogg)
- M4A (.m4a)
- FLAC (.flac)

Controls:
--------
- F9: Toggle Rhapsody UI
- Arrow Keys / WASD: Navigate
- Enter/Space: Select/Play
- Escape/Backspace: Back/Close
- I: Track details (in playlist view)

The UI features glassmorphism design, smooth animations, particle effects,
and music visualization. Tracks associated with jokers will show music
info directly in the joker's tooltip.
--]]--- STEAMODDED HEADER
--- MOD_NAME: Rhapsody
--- MOD_ID: Rhapsody
--- MOD_AUTHOR: [YourName]
--- MOD_DESCRIPTION: A comprehensive music manager for Balatro
--- BADGE_COLOUR: E91E63
--- PREFIX: rhap
--- VERSION: 1.0.0

----------------------------------------------
------------MOD CODE -------------------------

-- Initialize Rhapsody namespace
Rhapsody = {}

-- Load core modules
local core_modules = {
    "core/config",
    "core/storage", 
    "core/audio",
    "core/api",
    "ui/state",
    "ui/components",
    "ui/screens",
    "ui/main",
    "integration/hooks"
}

-- Load each module
for _, module in ipairs(core_modules) do
    local module_path = SMODS.current_mod.path .. module .. ".lua"
    local success, err = pcall(function()
        assert(SMODS.load_file(module_path))()
    end)
    
    if not success then
        print("Rhapsody: Failed to load module " .. module .. ": " .. tostring(err))
    else
        print("Rhapsody: Loaded module " .. module)
    end
end

-- Initialize the mod after all modules are loaded
if Rhapsody.init then
    Rhapsody.init()
    print("Rhapsody: Music manager initialized successfully")
else
    print("Rhapsody: Warning - init function not found")
end