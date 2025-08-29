-- core/config.lua
-- Configuration management for Rhapsody

return function()
    -- Default configuration
    Rhapsody.config = {
        music_folder = "music/",
        volume = 0.5,
        repeat_mode = false,
        current_track = nil,
        current_playlist = nil,
        ui_open = false,
        key_toggle = "f9",
        
        -- UI Settings
        tracks_per_page = 4,
        playlists_per_page = 4,
        
        -- Audio settings
        fade_duration = 0.5,
        auto_scan = true,
        
        -- File formats supported
        supported_formats = {
            ".mp3", ".wav", ".ogg", ".m4a", ".flac"
        }
    }
    
    -- Load saved config if exists
    function Rhapsody.load_config()
        -- This would integrate with Balatro's save system
        -- For now, use defaults
        print("Rhapsody: Config loaded")
    end
    
    -- Save config
    function Rhapsody.save_config()
        -- This would integrate with Balatro's save system
        print("Rhapsody: Config saved")
    end
    
    -- Validate file format
    function Rhapsody.is_supported_format(filename)
        local ext = filename:match("%.([^%.]+)$")
        if not ext then return false end
        
        ext = "." .. ext:lower()
        for _, format in ipairs(Rhapsody.config.supported_formats) do
            if format == ext then return true end
        end
        return false
    end
end