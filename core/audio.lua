-- core/audio.lua
-- Audio playback system for Rhapsody

return function()
    -- Audio state
    Rhapsody.audio = {
        current_source = nil,
        is_playing = false,
        position = 0,
        duration = 0,
        volume = 1.0
    }
    
    -- Play a track by key
    function Rhapsody.play_track(track_key)
        local track = Rhapsody.get_track(track_key)
        if not track then
            print("Rhapsody: Track not found: " .. tostring(track_key))
            return false
        end
        
        -- Stop current track
        Rhapsody.stop_track()
        
        -- Try to load and play the new track
        local success = Rhapsody.load_audio_file(track.path)
        if success then
            Rhapsody.config.current_track = track_key
            Rhapsody.audio.is_playing = true
            print("Rhapsody: Now playing '" .. track.name .. "' by " .. track.author)
            return true
        else
            print("Rhapsody: Failed to load track: " .. track.path)
            return false
        end
    end
    
    -- Stop current track
    function Rhapsody.stop_track()
        if Rhapsody.audio.current_source then
            -- Integration point: stop the audio source
            -- This depends on your audio system
            Rhapsody.audio.current_source = nil
        end
        
        Rhapsody.audio.is_playing = false
        Rhapsody.audio.position = 0
        Rhapsody.config.current_track = nil
    end
    
    -- Toggle playback
    function Rhapsody.toggle_playback()
        if Rhapsody.audio.is_playing then
            Rhapsody.pause_track()
        else
            if Rhapsody.config.current_track then
                Rhapsody.resume_track()
            end
        end
    end
    
    -- Pause current track
    function Rhapsody.pause_track()
        if Rhapsody.audio.current_source and Rhapsody.audio.is_playing then
            -- Integration point: pause audio
            Rhapsody.audio.is_playing = false
        end
    end
    
    -- Resume current track
    function Rhapsody.resume_track()
        if Rhapsody.audio.current_source and not Rhapsody.audio.is_playing then
            -- Integration point: resume audio
            Rhapsody.audio.is_playing = true
        end
    end
    
    -- Set volume (0.0 to 1.0)
    function Rhapsody.set_volume(volume)
        volume = math.max(0, math.min(1, volume))
        Rhapsody.audio.volume = volume
        Rhapsody.config.volume = volume
        
        if Rhapsody.audio.current_source then
            -- Integration point: set audio source volume
        end
    end
    
    -- Load audio file (integration point)
    function Rhapsody.load_audio_file(file_path)
        -- This needs to be integrated with your audio system
        -- For Love2D, this might be:
        -- local source = love.audio.newSource(file_path, "stream")
        -- Rhapsody.audio.current_source = source
        -- return source ~= nil
        
        -- Placeholder implementation
        print("Rhapsody: Loading audio file: " .. file_path)
        Rhapsody.audio.current_source = {path = file_path} -- Dummy source
        return true
    end
    
    -- Update audio system (called from main loop)
    function Rhapsody.update_audio(dt)
        if Rhapsody.audio.is_playing and Rhapsody.audio.current_source then
            -- Update playback position
            Rhapsody.audio.position = Rhapsody.audio.position + dt
            
            -- Check if track finished
            if Rhapsody.audio.duration > 0 and Rhapsody.audio.position >= Rhapsody.audio.duration then
                if Rhapsody.config.repeat_mode then
                    Rhapsody.audio.position = 0
                    -- Restart track
                else
                    Rhapsody.stop_track()
                    -- Auto-play next track if in playlist mode
                    Rhapsody.play_next_track()
                end
            end
        end
    end
    
    -- Play next track in current playlist
    function Rhapsody.play_next_track()
        if not Rhapsody.config.current_playlist then return end
        
        local playlist = Rhapsody.get_playlist(Rhapsody.config.current_playlist)
        if not playlist then return end
        
        local current_index = nil
        for i, track_key in ipairs(playlist.tracks) do
            if track_key == Rhapsody.config.current_track then
                current_index = i
                break
            end
        end
        
        if current_index and current_index < #playlist.tracks then
            local next_track_key = playlist.tracks[current_index + 1]
            Rhapsody.play_track(next_track_key)
        end
    end
    
    -- Play previous track in current playlist
    function Rhapsody.play_previous_track()
        if not Rhapsody.config.current_playlist then return end
        
        local playlist = Rhapsody.get_playlist(Rhapsody.config.current_playlist)
        if not playlist then return end
        
        local current_index = nil
        for i, track_key in ipairs(playlist.tracks) do
            if track_key == Rhapsody.config.current_track then
                current_index = i
                break
            end
        end
        
        if current_index and current_index > 1 then
            local prev_track_key = playlist.tracks[current_index - 1]
            Rhapsody.play_track(prev_track_key)
        end
    end
end