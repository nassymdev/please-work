-- integration/hooks.lua
-- Game integration hooks and event handling

return function()
    -- Initialize integration
    function Rhapsody.init_hooks()
        -- Hook into game's update loop
        local original_update = Game.update or function() end
        Game.update = function(dt)
            original_update(dt)
            if Rhapsody.config.ui_open then
                Rhapsody.ui.update(dt)
                Rhapsody.update_audio(dt)
            end
        end
        
        -- Hook into input system if available
        if love and love.keypressed then
            local original_keypressed = love.keypressed or function() end
            love.keypressed = function(key, scancode, isrepeat)
                original_keypressed(key, scancode, isrepeat)
                Rhapsody.handle_key_input(key, scancode, isrepeat)
            end
        end
        
        print("Rhapsody: Hooks initialized")
    end
    
    -- Key input handling
    function Rhapsody.handle_key_input(key, scancode, isrepeat)
        if not Rhapsody.config then return end
        
        -- Toggle UI with F9
        if key == "f9" and not isrepeat then
            Rhapsody.toggle_ui()
            return
        end
        
        -- Handle UI navigation only when UI is open
        if not Rhapsody.config.ui_open or not Rhapsody.ui.can_input() then
            return
        end
        
        -- Navigation based on current screen
        if Rhapsody.ui.is_on_screen("main") then
            Rhapsody.handle_main_screen_input(key)
        elseif Rhapsody.ui.is_on_screen("playlist") then
            Rhapsody.handle_playlist_screen_input(key)
        elseif Rhapsody.ui.is_on_screen("track_detail") then
            Rhapsody.handle_track_detail_input(key)
        end
        
        Rhapsody.ui.consume_input()
    end
    
    -- Main screen input
    function Rhapsody.handle_main_screen_input(key)
        local playlists, current_page, max_pages = Rhapsody.ui.get_playlist_page_items()
        
        if key == "up" or key == "w" then
            Rhapsody.ui.highlighted_playlist = math.max(1, Rhapsody.ui.highlighted_playlist - 1)
        elseif key == "down" or key == "s" then
            Rhapsody.ui.highlighted_playlist = math.min(#playlists, Rhapsody.ui.highlighted_playlist + 1)
        elseif key == "left" or key == "a" then
            Rhapsody.ui.previous_playlist_page()
        elseif key == "right" or key == "d" then
            Rhapsody.ui.next_playlist_page()
        elseif key == "return" or key == "space" then
            local selected = playlists[Rhapsody.ui.highlighted_playlist]
            if selected then
                Rhapsody.ui.navigate_to("playlist", {selected_playlist = selected.key})
            end
        elseif key == "escape" or key == "backspace" then
            Rhapsody.close_ui()
        end
    end
    
    -- Playlist screen input
    function Rhapsody.handle_playlist_screen_input(key)
        local tracks, current_page, max_pages = Rhapsody.ui.get_track_page_items()
        
        if key == "up" or key == "w" then
            Rhapsody.ui.highlighted_track = math.max(1, Rhapsody.ui.highlighted_track - 1)
        elseif key == "down" or key == "s" then
            Rhapsody.ui.highlighted_track = math.min(#tracks, Rhapsody.ui.highlighted_track + 1)
        elseif key == "left" or key == "a" then
            Rhapsody.ui.previous_track_page()
        elseif key == "right" or key == "d" then
            Rhapsody.ui.next_track_page()
        elseif key == "return" or key == "space" then
            local selected = tracks[Rhapsody.ui.highlighted_track]
            if selected then
                Rhapsody.play_track(selected.key)
                Rhapsody.config.current_playlist = Rhapsody.ui.selected_playlist
            end
        elseif key == "i" then
            local selected = tracks[Rhapsody.ui.highlighted_track]
            if selected then
                Rhapsody.ui.navigate_to("track_detail", {selected_track = selected.key})
            end
        elseif key == "escape" or key == "backspace" then
            Rhapsody.ui.navigate_back()
        end
    end
    
    -- Track detail input
    function Rhapsody.handle_track_detail_input(key)
        if key == "return" or key == "space" then
            if Rhapsody.ui.selected_track then
                Rhapsody.play_track(Rhapsody.ui.selected_track)
                Rhapsody.config.current_playlist = Rhapsody.ui.selected_playlist
            end
        elseif key == "escape" or key == "backspace" then
            Rhapsody.ui.navigate_back()
        end
    end
    
    -- UI toggle functions
    function Rhapsody.toggle_ui()
        if Rhapsody.config.ui_open then
            Rhapsody.close_ui()
        else
            Rhapsody.open_ui()
        end
    end
    
    function Rhapsody.open_ui()
        Rhapsody.config.ui_open = true
        Rhapsody.ui.reset()
        print("Rhapsody: UI opened")
    end
    
    function Rhapsody.close_ui()
        Rhapsody.config.ui_open = false
        print("Rhapsody: UI closed")
    end
    
    -- Joker integration hooks
    function Rhapsody.hook_joker_text()
        -- Hook into joker text generation system
        local original_generate_ui = Card.generate_UIBox_ability_table or function() return {} end
        
        Card.generate_UIBox_ability_table = function(self)
            local ui_table = original_generate_ui(self)
            
            -- Check if this joker has associated music
            local track = Rhapsody.get_track_for_joker(self.config.center.key)
            if track then
                -- Add music note indicator
                table.insert(ui_table, {
                    n = G.UIT.R,
                    config = {align = "cm", padding = 0.05},
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = "♪ " .. track.name .. " by " .. track.author,
                                colour = G.C.PURPLE,
                                scale = 0.3
                            }
                        }
                    }
                })
            end
            
            return ui_table
        end
    end
    
    -- Game state hooks
    function Rhapsody.hook_game_state()
        -- Hook into game state changes to auto-play contextual music
        local original_change_state = Game.change_state or function() end
        
        Game.change_state = function(new_state)
            original_change_state(new_state)
            
            -- Auto-play music based on game state
            if new_state == "menu" and Rhapsody.get_track("menu_theme") then
                Rhapsody.play_track("menu_theme")
            elseif new_state == "game" and Rhapsody.get_track("game_theme") then
                Rhapsody.play_track("game_theme")
            end
        end
    end
    
    -- Initialize all hooks
    function Rhapsody.init_all_hooks()
        Rhapsody.init_hooks()
        Rhapsody.hook_joker_text()
        Rhapsody.hook_game_state()
        print("Rhapsody: All hooks initialized")
    end
end