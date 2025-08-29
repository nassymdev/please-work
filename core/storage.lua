-- core/storage.lua
-- Data storage and management for tracks and playlists

return function()
    -- Storage containers
    Rhapsody.tracks = {}
    Rhapsody.playlists = {}
    Rhapsody.custom_tracks = {}
    
    -- Get all playlists as array
    function Rhapsody.get_playlists()
        local playlists = {}
        for key, playlist in pairs(Rhapsody.playlists) do
            table.insert(playlists, playlist)
        end
        
        -- Sort: custom playlist first, then alphabetically
        table.sort(playlists, function(a, b)
            if a.key == "custom" then return true end
            if b.key == "custom" then return false end
            return a.name < b.name
        end)
        
        return playlists
    end
    
    -- Get tracks for a playlist
    function Rhapsody.get_playlist_tracks(playlist_key)
        local playlist = Rhapsody.playlists[playlist_key]
        if not playlist then return {} end
        
        local tracks = {}
        for _, track_key in ipairs(playlist.tracks) do
            local track = Rhapsody.tracks[track_key]
            if track then
                table.insert(tracks, track)
            end
        end
        
        return tracks
    end
    
    -- Get track by key
    function Rhapsody.get_track(track_key)
        return Rhapsody.tracks[track_key]
    end
    
    -- Get playlist by key  
    function Rhapsody.get_playlist(playlist_key)
        return Rhapsody.playlists[playlist_key]
    end
    
    -- Find track by joker key
    function Rhapsody.get_track_for_joker(joker_key)
        for _, track in pairs(Rhapsody.tracks) do
            if track.joker == joker_key then
                return track
            end
        end
        return nil
    end
    
    -- Get total number of playlists
    function Rhapsody.get_playlist_count()
        local count = 0
        for _ in pairs(Rhapsody.playlists) do
            count = count + 1
        end
        return count
    end
    
    -- Get total number of tracks
    function Rhapsody.get_track_count()
        local count = 0
        for _ in pairs(Rhapsody.tracks) do
            count = count + 1
        end
        return count
    end
    
    -- Clear all data (for reloading)
    function Rhapsody.clear_data()
        Rhapsody.tracks = {}
        Rhapsody.playlists = {}
        Rhapsody.custom_tracks = {}
    end
end