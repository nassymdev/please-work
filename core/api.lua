-- core/api.lua
-- Public API for other mods to register tracks and playlists

return function()
    -- Register a track (public API)
    function Rhapsody.track(data)
        -- Validate required fields
        if not data or type(data) ~= "table" then
            print("Rhapsody: Invalid track data - must be a table")
            return false
        end
        
        if not data.Key or not data.Name or not data.Path then
            print("Rhapsody: Invalid track data - missing required fields (Key, Name, Path)")
            return false
        end
        
        -- Validate key uniqueness
        if Rhapsody.tracks[data.Key] then
            print("Rhapsody: Warning - Track key '" .. data.Key .. "' already exists, overwriting")
        end
        
        -- Create track entry
        Rhapsody.tracks[data.Key] = {
            key = data.Key,
            name = data.Name,
            author = data.Author or "Unknown Artist",
            text = data.Text or {},
            path = data.Path,
            joker = data.Joker or nil,
            custom = false,
            mod_id = SMODS.current_mod and SMODS.current_mod.id or "unknown"
        }
        
        print("Rhapsody: Registered track '" .. data.Name .. "' with key '" .. data.Key .. "'")
        return true
    end
    
    -- Register a playlist (public API)
    function Rhapsody.playlist(data)
        -- Validate required fields
        if not data or type(data) ~= "table" then
            print("Rhapsody: Invalid playlist data - must be a table")
            return false
        end
        
        if not data.Key or not data.Name then
            print("Rhapsody: Invalid playlist data - missing required fields (Key, Name)")
            return false
        end
        
        -- Validate key uniqueness
        if Rhapsody.playlists[data.Key] then
            print("Rhapsody: Warning - Playlist key '" .. data.Key .. "' already exists, overwriting")
        end
        
        -- Validate tracks exist
        local valid_tracks = {}
        if data.Tracks then
            for _, track_key in ipairs(data.Tracks) do
                if Rhapsody.tracks[track_key] then
                    table.insert(valid_tracks, track_key)
                else
                    print("Rhapsody: Warning - Track '" .. track_key .. "' not found for playlist '" .. data.Key .. "'")
                end
            end
        end
        
        -- Create playlist entry
        Rhapsody.playlists[data.Key] = {
            key = data.Key,
            name = data.Name,
            tracks = valid_tracks,
            custom = false,
            mod_id = SMODS.current_mod and SMODS.current_mod.id or "unknown"
        }
        
        print("Rhapsody: Registered playlist '" .. data.Name .. "' with key '" .. data.Key .. "' (" .. #valid_tracks .. " tracks)")
        return true
    end
    
    -- Scan for custom music files in the music folder
    function Rhapsody.scan_custom_music()
        local custom_tracks = {}
        
        -- This needs to be adapted based on file system access in your environment
        -- For now, create a placeholder system that would work with a file scanning function
        
        local function scan_directory(directory)
            -- Placeholder: In a real implementation, this would scan the actual directory
            -- and return a list of files
            local files = {} -- This should be populated with actual file scanning
            
            -- Example files for testing (remove in production)
            files = {
                "custom_song_1.mp3",
                "background_music.ogg",
                "victory_theme.wav"
            }
            
            return files
        end
        
        local music_files = scan_directory(Rhapsody.config.music_folder)
        local track_index = 1
        
        for _, file in ipairs(music_files) do
            if Rhapsody.is_supported_format(file) then
                local key = "custom_" .. track_index
                local name = file:match("([^/\\]+)%.[^%.]*$") or file -- Extract filename without extension
                name = name:gsub("%.[^%.]*$", "") -- Remove extension
                name = name:gsub("_", " "):gsub("%-", " ") -- Replace underscores and hyphens with spaces
                
                -- Capitalize first letter of each word
                name = name:gsub("(%a)([%w_']*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                
                Rhapsody.tracks[key] = {
                    key = key,
                    name = name,
                    author = "Custom",
                    text = {"Custom imported track from " .. file},
                    path = Rhapsody.config.music_folder .. file,
                    joker = nil,
                    custom = true,
                    mod_id = "rhapsody"
                }
                
                table.insert(custom_tracks, key)
                track_index = track_index + 1
            end
        end
        
        -- Create or update custom playlist
        Rhapsody.playlists["custom"] = {
            key = "custom",
            name = "Custom Music",
            tracks = custom_tracks,
            custom = true,
            mod_id = "rhapsody"
        }
        
        print("Rhapsody: Scanned custom music folder - found " .. #custom_tracks .. " tracks")
        return #custom_tracks
    end
    
    -- Get current playing track info
    function Rhapsody.get_current_track_info()
        if not Rhapsody.config.current_track then
            return nil
        end
        
        return Rhapsody.get_track(Rhapsody.config.current_track)
    end
    
    -- Check if a specific track is currently playing
    function Rhapsody.is_track_playing(track_key)
        return Rhapsody.config.current_track == track_key and Rhapsody.audio.is_playing
    end
    
    -- Get playback status
    function Rhapsody.get_playback_status()
        return {
            is_playing = Rhapsody.audio.is_playing,
            current_track = Rhapsody.config.current_track,
            current_playlist = Rhapsody.config.current_playlist,
            position = Rhapsody.audio.position,
            duration = Rhapsody.audio.duration,
            volume = Rhapsody.audio.volume
        }
    end
    
    -- Initialize custom music scanning
    function Rhapsody.init_custom_music()
        if Rhapsody.config.auto_scan then
            Rhapsody.scan_custom_music()
        end
    end
end