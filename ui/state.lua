-- ui/state.lua
-- UI state management for Rhapsody

return function()
    -- UI state container
    Rhapsody.ui = {
        -- Screen management
        current_screen = "main",        -- "main", "playlist", "track_detail"
        previous_screen = nil,
        screen_stack = {},
        
        -- Selection state
        selected_playlist = nil,
        selected_track = nil,
        highlighted_playlist = 1,
        highlighted_track = 1,
        
        -- Pagination
        current_page = 1,
        playlist_page = 1,
        
        -- Animation state
        transition_alpha = 0,
        transitioning = false,
        transition_direction = 1,
        
        -- Input state
        input_cooldown = 0,
        input_delay = 0.15,
        
        -- Layout
        window_width = 720,
        window_height = 480,
        margin = 20,
        button_height = 60,
        spacing = 10
    }
    
    -- Navigation functions
    function Rhapsody.ui.navigate_to(screen, data)
        if Rhapsody.ui.current_screen == screen then return end
        
        -- Push current screen to stack
        table.insert(Rhapsody.ui.screen_stack, {
            screen = Rhapsody.ui.current_screen,
            data = {
                selected_playlist = Rhapsody.ui.selected_playlist,
                selected_track = Rhapsody.ui.selected_track,
                current_page = Rhapsody.ui.current_page,
                playlist_page = Rhapsody.ui.playlist_page
            }
        })
        
        -- Set new screen
        Rhapsody.ui.previous_screen = Rhapsody.ui.current_screen
        Rhapsody.ui.current_screen = screen
        
        -- Apply data if provided
        if data then
            if data.selected_playlist then
                Rhapsody.ui.selected_playlist = data.selected_playlist
            end
            if data.selected_track then
                Rhapsody.ui.selected_track = data.selected_track
            end
        end
        
        -- Reset pagination for new screen
        Rhapsody.ui.current_page = 1
        Rhapsody.ui.highlighted_track = 1
        
        print("Rhapsody: Navigated to screen: " .. screen)
    end
    
    function Rhapsody.ui.navigate_back()
        if #Rhapsody.ui.screen_stack == 0 then
            -- No previous screen, go to main or close
            if Rhapsody.ui.current_screen ~= "main" then
                Rhapsody.ui.navigate_to("main")
            else
                Rhapsody.close_ui()
            end
            return
        end
        
        -- Pop previous screen from stack
        local previous = table.remove(Rhapsody.ui.screen_stack)
        Rhapsody.ui.current_screen = previous.screen
        
        -- Restore previous state
        if previous.data then
            Rhapsody.ui.selected_playlist = previous.data.selected_playlist
            Rhapsody.ui.selected_track = previous.data.selected_track
            Rhapsody.ui.current_page = previous.data.current_page
            Rhapsody.ui.playlist_page = previous.data.playlist_page
        end
    end
    
    -- Pagination functions
    function Rhapsody.ui.get_playlist_page_items()
        local playlists = Rhapsody.get_playlists()
        local per_page = Rhapsody.config.playlists_per_page
        local start_index = (Rhapsody.ui.playlist_page - 1) * per_page + 1
        local end_index = math.min(start_index + per_page - 1, #playlists)
        
        local page_items = {}
        for i = start_index, end_index do
            table.insert(page_items, playlists[i])
        end
        
        return page_items, Rhapsody.ui.playlist_page, math.ceil(#playlists / per_page)
    end
    
    function Rhapsody.ui.get_track_page_items()
        if not Rhapsody.ui.selected_playlist then return {}, 1, 1 end
        
        local tracks = Rhapsody.get_playlist_tracks(Rhapsody.ui.selected_playlist)
        local per_page = Rhapsody.config.tracks_per_page
        local start_index = (Rhapsody.ui.current_page - 1) * per_page + 1
        local end_index = math.min(start_index + per_page - 1, #tracks)
        
        local page_items = {}
        for i = start_index, end_index do
            table.insert(page_items, tracks[i])
        end
        
        return page_items, Rhapsody.ui.current_page, math.ceil(#tracks / per_page)
    end
    
    function Rhapsody.ui.next_playlist_page()
        local _, current_page, max_pages = Rhapsody.ui.get_playlist_page_items()
        if current_page < max_pages then
            Rhapsody.ui.playlist_page = Rhapsody.ui.playlist_page + 1
            Rhapsody.ui.highlighted_playlist = 1
        end
    end
    
    function Rhapsody.ui.previous_playlist_page()
        if Rhapsody.ui.playlist_page > 1 then
            Rhapsody.ui.playlist_page = Rhapsody.ui.playlist_page - 1
            Rhapsody.ui.highlighted_playlist = 1
        end
    end
    
    function Rhapsody.ui.next_track_page()
        local _, current_page, max_pages = Rhapsody.ui.get_track_page_items()
        if current_page < max_pages then
            Rhapsody.ui.current_page = Rhapsody.ui.current_page + 1
            Rhapsody.ui.highlighted_track = 1
        end
    end
    
    function Rhapsody.ui.previous_track_page()
        if Rhapsody.ui.current_page > 1 then
            Rhapsody.ui.current_page = Rhapsody.ui.current_page - 1
            Rhapsody.ui.highlighted_track = 1
        end
    end
    
    -- Input handling
    function Rhapsody.ui.update(dt)
        -- Update input cooldown
        if Rhapsody.ui.input_cooldown > 0 then
            Rhapsody.ui.input_cooldown = Rhapsody.ui.input_cooldown - dt
        end
        
        -- Update transitions
        if Rhapsody.ui.transitioning then
            Rhapsody.ui.transition_alpha = Rhapsody.ui.transition_alpha + (dt * 4 * Rhapsody.ui.transition_direction)
            
            if Rhapsody.ui.transition_alpha >= 1 then
                Rhapsody.ui.transition_alpha = 1
                Rhapsody.ui.transitioning = false
            elseif Rhapsody.ui.transition_alpha <= 0 then
                Rhapsody.ui.transition_alpha = 0
                Rhapsody.ui.transitioning = false
            end
        end
    end
    
    function Rhapsody.ui.can_input()
        return Rhapsody.ui.input_cooldown <= 0
    end
    
    function Rhapsody.ui.consume_input()
        Rhapsody.ui.input_cooldown = Rhapsody.ui.input_delay
    end
    
    -- State queries
    function Rhapsody.ui.is_on_screen(screen_name)
        return Rhapsody.ui.current_screen == screen_name
    end
    
    function Rhapsody.ui.get_current_screen_data()
        return {
            screen = Rhapsody.ui.current_screen,
            selected_playlist = Rhapsody.ui.selected_playlist,
            selected_track = Rhapsody.ui.selected_track,
            current_page = Rhapsody.ui.current_page,
            playlist_page = Rhapsody.ui.playlist_page
        }
    end
    
    -- Reset UI state
    function Rhapsody.ui.reset()
        Rhapsody.ui.current_screen = "main"
        Rhapsody.ui.previous_screen = nil
        Rhapsody.ui.screen_stack = {}
        Rhapsody.ui.selected_playlist = nil
        Rhapsody.ui.selected_track = nil
        Rhapsody.ui.highlighted_playlist = 1
        Rhapsody.ui.highlighted_track = 1
        Rhapsody.ui.current_page = 1
        Rhapsody.ui.playlist_page = 1
        Rhapsody.ui.transitioning = false
        Rhapsody.ui.transition_alpha = 0
    end
end