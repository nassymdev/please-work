-- ui/screens.lua
-- Screen layouts and rendering for Rhapsody UI

return function()
    -- Screen data storage
    Rhapsody.ui.screens = {
        main = {},
        playlist = {},
        track_detail = {}
    }
    
    -- Colors and styling
    local colors = {
        background = {0.1, 0.1, 0.15, 0.95},
        panel = {0.15, 0.15, 0.2, 0.9},
        accent = {0.8, 0.2, 0.8, 1.0},
        text_primary = {1.0, 1.0, 1.0, 1.0},
        text_secondary = {0.8, 0.8, 0.9, 1.0},
        text_muted = {0.6, 0.6, 0.7, 1.0},
        highlight = {0.9, 0.3, 0.9, 0.3},
        playing = {0.2, 0.8, 0.2, 1.0},
        border = {0.3, 0.3, 0.4, 0.6}
    }
    
    -- Initialize main screen components
    function Rhapsody.ui.init_main_screen()
        local screen = Rhapsody.ui.screens.main
        
        -- Background panel
        screen.background = Rhapsody.ui.create_glassmorphism_panel(50, 50, 620, 380, 0.8)
        
        -- Title with glow effect
        screen.title = Rhapsody.ui.create_glowing_text("Rhapsody Music Manager", 360, 80, 1.2, colors.text_primary, colors.accent)
        
        -- Music visualizer (decorative)
        screen.visualizer = Rhapsody.ui.create_music_visualizer(60, 320, 200, 60, 12)
        
        -- Control buttons
        screen.play_button = Rhapsody.ui.create_animated_button(280, 320, 80, 35, "Play/Pause", function()
            Rhapsody.toggle_playback()
            Rhapsody.ui.create_music_note_effect(320, 337)
        end)
        
        screen.repeat_button = Rhapsody.ui.create_animated_button(370, 320, 60, 35, "Repeat", function()
            Rhapsody.config.repeat_mode = not Rhapsody.config.repeat_mode
            Rhapsody.ui.create_button_click_effect(400, 337)
        end)
        
        -- Back button
        screen.back_button = Rhapsody.ui.create_animated_button(480, 320, 160, 35, "Back", function()
            Rhapsody.close_ui()
        end)
        
        -- Progress ring for current track
        screen.progress_ring = Rhapsody.ui.create_progress_ring(620, 320, 25, 0, colors.accent)
        
        print("Rhapsody: Main screen initialized")
    end
    
    -- Initialize playlist screen components
    function Rhapsody.ui.init_playlist_screen()
        local screen = Rhapsody.ui.screens.playlist
        
        -- Background panel
        screen.background = Rhapsody.ui.create_glassmorphism_panel(50, 50, 620, 380, 0.8)
        
        -- Track list area
        screen.track_panels = {}
        for i = 1, Rhapsody.config.tracks_per_page do
            local y_pos = 120 + (i - 1) * 45
            screen.track_panels[i] = {
                panel = Rhapsody.ui.create_glassmorphism_panel(70, y_pos, 580, 40, 0.6),
                play_button = Rhapsody.ui.create_animated_button(75, y_pos + 5, 30, 30, "►", nil),
                highlight_alpha = 0.0
            }
        end
        
        -- Navigation buttons
        screen.prev_button = Rhapsody.ui.create_animated_button(270, 350, 30, 30, "<", function()
            Rhapsody.ui.previous_track_page()
        end)
        
        screen.next_button = Rhapsody.ui.create_animated_button(420, 350, 30, 30, ">", function()
            Rhapsody.ui.next_track_page()
        end)
        
        -- Back button
        screen.back_button = Rhapsody.ui.create_animated_button(480, 390, 160, 35, "Back", function()
            Rhapsody.ui.navigate_back()
        end)
        
        print("Rhapsody: Playlist screen initialized")
    end
    
    -- Initialize track detail screen components  
    function Rhapsody.ui.init_track_detail_screen()
        local screen = Rhapsody.ui.screens.track_detail
        
        -- Background panel
        screen.background = Rhapsody.ui.create_glassmorphism_panel(50, 50, 620, 380, 0.8)
        
        -- Album art placeholder (could be joker image)
        screen.album_art = Rhapsody.ui.create_glassmorphism_panel(80, 100, 200, 200, 0.4)
        
        -- Track info panel
        screen.info_panel = Rhapsody.ui.create_glassmorphism_panel(300, 100, 340, 200, 0.4)
        
        -- Control buttons
        screen.play_button = Rhapsody.ui.create_animated_button(300, 320, 100, 40, "Play Track", function()
            if Rhapsody.ui.selected_track then
                Rhapsody.play_track(Rhapsody.ui.selected_track)
                Rhapsody.config.current_playlist = Rhapsody.ui.selected_playlist
                Rhapsody.ui.create_music_note_effect(350, 340)
            end
        end)
        
        screen.back_button = Rhapsody.ui.create_animated_button(480, 390, 160, 35, "Back", function()
            Rhapsody.ui.navigate_back()
        end)
        
        print("Rhapsody: Track detail screen initialized")
    end
    
    -- Render main screen
    function Rhapsody.ui.render_main_screen(dt)
        local screen = Rhapsody.ui.screens.main
        
        -- Render background
        Rhapsody.ui.render_glassmorphism_panel(screen.background)
        
        -- Render title with wave effect
        screen.title.wave_offset = screen.title.wave_offset + dt * 2
        
        -- Render visualizer
        Rhapsody.ui.render_music_visualizer(screen.visualizer, dt)
        
        -- Render playlist grid
        local playlists, current_page, max_pages = Rhapsody.ui.get_playlist_page_items()
        
        -- Calculate grid layout (2x2 for 4 playlists per page)
        local grid_start_x, grid_start_y = 300, 120
        local grid_spacing_x, grid_spacing_y = 160, 80
        
        for i, playlist in ipairs(playlists) do
            local col = ((i - 1) % 2)
            local row = math.floor((i - 1) / 2)
            local x = grid_start_x + col * grid_spacing_x
            local y = grid_start_y + row * grid_spacing_y
            
            -- Create playlist button with glow effect if highlighted
            local is_highlighted = (i == Rhapsody.ui.highlighted_playlist)
            local button_color = is_highlighted and colors.highlight or colors.panel
            
            -- Render playlist panel with animation
            local panel = Rhapsody.ui.create_glassmorphism_panel(x, y, 150, 70, 0.6)
            panel.glow_intensity = is_highlighted and 0.8 or 0.0
            Rhapsody.ui.render_glassmorphism_panel(panel)
            
            -- Render playlist name and track count
            local track_count = #playlist.tracks
            local display_text = playlist.name .. " (" .. track_count .. ")"
            
            -- Add special icon for custom playlist
            if playlist.key == "custom" then
                display_text = "♪ " .. display_text
            end
            
            print("Rendering playlist: " .. display_text .. " at " .. x .. "," .. y)
        end
        
        -- Render pagination info
        if max_pages > 1 then
            local page_text = current_page .. "/" .. max_pages
            print("Rendering pagination: " .. page_text)
        end
        
        -- Render control buttons
        Rhapsody.ui.render_animated_button(screen.play_button, dt)
        Rhapsody.ui.render_animated_button(screen.repeat_button, dt)
        Rhapsody.ui.render_animated_button(screen.back_button, dt)
        
        -- Update progress ring based on current track
        if Rhapsody.config.current_track and Rhapsody.audio.duration > 0 then
            screen.progress_ring.progress = Rhapsody.audio.position / Rhapsody.audio.duration
        else
            screen.progress_ring.progress = 0
        end
        Rhapsody.ui.render_progress_ring(screen.progress_ring)
    end
    
    -- Render playlist screen
    function Rhapsody.ui.render_playlist_screen(dt)
        local screen = Rhapsody.ui.screens.playlist
        
        -- Render background
        Rhapsody.ui.render_glassmorphism_panel(screen.background)
        
        -- Get current playlist info
        local playlist = Rhapsody.get_playlist(Rhapsody.ui.selected_playlist)
        if not playlist then return end
        
        -- Render playlist title
        local title_text = "Playlist: " .. playlist.name
        print("Rendering playlist title: " .. title_text)
        
        -- Render tracks
        local tracks, current_page, max_pages = Rhapsody.ui.get_track_page_items()
        
        for i, track in ipairs(tracks) do
            local panel_data = screen.track_panels[i]
            if panel_data then
                local is_highlighted = (i == Rhapsody.ui.highlighted_track)
                local is_playing = Rhapsody.is_track_playing(track.key)
                
                -- Animate highlight
                local target_alpha = is_highlighted and 0.8 or 0.0
                local alpha_diff = target_alpha - panel_data.highlight_alpha
                panel_data.highlight_alpha = panel_data.highlight_alpha + alpha_diff * dt * 6
                
                -- Render track panel
                panel_data.panel.alpha = 0.15 + panel_data.highlight_alpha * 0.2
                Rhapsody.ui.render_glassmorphism_panel(panel_data.panel)
                
                -- Update play button
                panel_data.play_button.text = is_playing and "⏸" or "►"
                panel_data.play_button.callback = function()
                    if is_playing then
                        Rhapsody.stop_track()
                    else
                        Rhapsody.play_track(track.key)
                        Rhapsody.config.current_playlist = Rhapsody.ui.selected_playlist
                    end
                    Rhapsody.ui.create_music_note_effect(panel_data.play_button.x + 15, panel_data.play_button.y + 15)
                end
                
                Rhapsody.ui.render_animated_button(panel_data.play_button, dt)
                
                -- Render track info
                local track_text = track.name .. " - " .. track.author
                if is_playing then
                    track_text = "♫ " .. track_text .. " ♫"
                end
                
                print("Rendering track " .. i .. ": " .. track_text)
                
                -- Show additional track text if available
                if track.text and #track.text > 0 then
                    for j, text_line in ipairs(track.text) do
                        print("  Track text " .. j .. ": " .. text_line)
                    end
                end
            end
        end
        
        -- Render pagination
        if max_pages > 1 then
            Rhapsody.ui.render_animated_button(screen.prev_button, dt)
            Rhapsody.ui.render_animated_button(screen.next_button, dt)
            
            local page_text = current_page .. "/" .. max_pages
            print("Rendering track pagination: " .. page_text)
        end
        
        -- Render back button
        Rhapsody.ui.render_animated_button(screen.back_button, dt)
    end
    
    -- Render track detail screen
    function Rhapsody.ui.render_track_detail_screen(dt)
        local screen = Rhapsody.ui.screens.track_detail
        
        -- Render background
        Rhapsody.ui.render_glassmorphism_panel(screen.background)
        
        -- Get track info
        local track = Rhapsody.get_track(Rhapsody.ui.selected_track)
        if not track then return end
        
        -- Render album art area (could show joker image if available)
        Rhapsody.ui.render_glassmorphism_panel(screen.album_art)
        
        -- If track has associated joker, try to render joker preview
        if track.joker then
            print("Rendering joker preview for: " .. track.joker)
            -- This would integrate with the game's joker rendering system
        else
            -- Show generic music note symbol
            print("Rendering generic music symbol")
        end
        
        -- Render info panel
        Rhapsody.ui.render_glassmorphism_panel(screen.info_panel)
        
        -- Render track details
        local track_title = Rhapsody.ui.create_glowing_text(track.name, 320, 120, 1.0, colors.text_primary, colors.accent)
        local track_artist = Rhapsody.ui.create_glowing_text("by " .. track.author, 320, 145, 0.8, colors.text_secondary, colors.accent)
        
        print("Rendering track title: " .. track.name)
        print("Rendering track artist: " .. track.author)
        
        -- Render track description text
        local y_offset = 170
        if track.text and #track.text > 0 then
            for i, text_line in ipairs(track.text) do
                print("Rendering track text " .. i .. ": " .. text_line .. " at y=" .. y_offset)
                y_offset = y_offset + 20
            end
        end
        
        -- Show file info
        local file_info = "File: " .. track.path
        print("Rendering file info: " .. file_info)
        
        -- Show if track is currently playing
        local is_playing = Rhapsody.is_track_playing(track.key)
        if is_playing then
            print("Rendering 'NOW PLAYING' indicator")
            -- Add pulsing effect
            local pulse_alpha = 0.5 + 0.3 * math.sin(love.timer.getTime() * 4)
            screen.play_button.glow_intensity = pulse_alpha
        end
        
        -- Update play button text
        screen.play_button.text = is_playing and "⏸ Pause Track" or "► Play Track"
        
        -- Render control buttons
        Rhapsody.ui.render_animated_button(screen.play_button, dt)
        Rhapsody.ui.render_animated_button(screen.back_button, dt)
    end
    
    -- Master render function
    function Rhapsody.ui.render_current_screen(dt)
        if not Rhapsody.config.ui_open then return end
        
        -- Update all components first
        Rhapsody.ui.update_all_components(dt)
        
        -- Render current screen
        if Rhapsody.ui.is_on_screen("main") then
            Rhapsody.ui.render_main_screen(dt)
        elseif Rhapsody.ui.is_on_screen("playlist") then
            Rhapsody.ui.render_playlist_screen(dt)
        elseif Rhapsody.ui.is_on_screen("track_detail") then
            Rhapsody.ui.render_track_detail_screen(dt)
        end
        
        -- Render particles and effects on top
        Rhapsody.ui.render_particles()
        
        -- Render transition effects
        if Rhapsody.ui.transitioning then
            print("Rendering screen transition: " .. Rhapsody.ui.transition_alpha)
        end
    end
    
    -- Initialize all screens
    function Rhapsody.ui.init_all_screens()
        Rhapsody.ui.init_main_screen()
        Rhapsody.ui.init_playlist_screen()
        Rhapsody.ui.init_track_detail_screen()
        print("Rhapsody: All screens initialized")
    end
    
    -- Screen transition effects
    function Rhapsody.ui.start_screen_transition(direction)
        Rhapsody.ui.transitioning = true
        Rhapsody.ui.transition_direction = direction or 1
        Rhapsody.ui.transition_alpha = 0
    end
    
    -- Handle screen-specific click events
    function Rhapsody.ui.handle_screen_click(x, y)
        if not Rhapsody.config.ui_open then return false end
        
        local handled = false
        
        if Rhapsody.ui.is_on_screen("main") then
            handled = Rhapsody.ui.handle_main_screen_click(x, y)
        elseif Rhapsody.ui.is_on_screen("playlist") then
            handled = Rhapsody.ui.handle_playlist_screen_click(x, y)
        elseif Rhapsody.ui.is_on_screen("track_detail") then
            handled = Rhapsody.ui.handle_track_detail_click(x, y)
        end
        
        return handled
    end
    
    function Rhapsody.ui.handle_main_screen_click(x, y)
        local screen = Rhapsody.ui.screens.main
        
        -- Check control buttons
        if Rhapsody.ui.handle_button_click(screen.play_button, x, y) then return true end
        if Rhapsody.ui.handle_button_click(screen.repeat_button, x, y) then return true end
        if Rhapsody.ui.handle_button_click(screen.back_button, x, y) then return true end
        
        -- Check playlist grid clicks
        local playlists = Rhapsody.get_playlists()
        local grid_start_x, grid_start_y = 300, 120
        local grid_spacing_x, grid_spacing_y = 160, 80
        
        for i, playlist in ipairs(playlists) do
            if i <= Rhapsody.config.playlists_per_page then
                local col = ((i - 1) % 2)
                local row = math.floor((i - 1) / 2)
                local panel_x = grid_start_x + col * grid_spacing_x
                local panel_y = grid_start_y + row * grid_spacing_y
                
                if x >= panel_x and x <= panel_x + 150 and y >= panel_y and y <= panel_y + 70 then
                    Rhapsody.ui.navigate_to("playlist", {selected_playlist = playlist.key})
                    Rhapsody.ui.create_button_click_effect(x, y)
                    return true
                end
            end
        end
        
        return false
    end
    
    function Rhapsody.ui.handle_playlist_screen_click(x, y)
        local screen = Rhapsody.ui.screens.playlist
        
        -- Check navigation buttons
        if Rhapsody.ui.handle_button_click(screen.prev_button, x, y) then return true end
        if Rhapsody.ui.handle_button_click(screen.next_button, x, y) then return true end
        if Rhapsody.ui.handle_button_click(screen.back_button, x, y) then return true end
        
        -- Check track clicks
        local tracks = Rhapsody.ui.get_track_page_items()
        
        for i, track in ipairs(tracks) do
            local panel_data = screen.track_panels[i]
            if panel_data then
                -- Check play button
                if Rhapsody.ui.handle_button_click(panel_data.play_button, x, y) then
                    return true
                end
                
                -- Check track panel for detail view
                local panel = panel_data.panel
                if x >= panel.x and x <= panel.x + panel.w and y >= panel.y and y <= panel.y + panel.h then
                    Rhapsody.ui.navigate_to("track_detail", {selected_track = track.key})
                    Rhapsody.ui.create_button_click_effect(x, y)
                    return true
                end
            end
        end
        
        return false
    end
    
    function Rhapsody.ui.handle_track_detail_click(x, y)
        local screen = Rhapsody.ui.screens.track_detail
        
        -- Check control buttons
        if Rhapsody.ui.handle_button_click(screen.play_button, x, y) then return true end
        if Rhapsody.ui.handle_button_click(screen.back_button, x, y) then return true end
        
        return false
    end
end