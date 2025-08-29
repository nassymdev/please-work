-- ui/main.lua
-- Main UI integration and rendering system

return function()
    -- UI integration state
    Rhapsody.ui.integration = {
        initialized = false,
        render_hook = nil,
        input_hook = nil,
        mouse_x = 0,
        mouse_y = 0
    }
    
    -- Initialize the complete UI system
    function Rhapsody.init_ui()
        if Rhapsody.ui.integration.initialized then return end
        
        -- Initialize all UI components
        Rhapsody.ui.init_all_screens()
        
        -- Set up rendering hooks
        Rhapsody.setup_ui_hooks()
        
        -- Initialize joker text integration
        Rhapsody.init_joker_text_integration()
        
        Rhapsody.ui.integration.initialized = true
        print("Rhapsody: UI system fully initialized")
    end
    
    -- Set up UI rendering and input hooks
    function Rhapsody.setup_ui_hooks()
        -- Hook into the game's rendering system
        local original_render = Game.render or function() end
        Game.render = function()
            original_render()
            
            -- Render Rhapsody UI on top
            if Rhapsody.config.ui_open then
                Rhapsody.ui.render_current_screen(love.timer.getDelta())
            end
        end
        
        -- Hook into mouse input if available
        if love and love.mousepressed then
            local original_mousepressed = love.mousepressed or function() end
            love.mousepressed = function(x, y, button, istouch, presses)
                original_mousepressed(x, y, button, istouch, presses)
                
                if Rhapsody.config.ui_open and button == 1 then
                    Rhapsody.ui.handle_screen_click(x, y)
                end
            end
        end
        
        -- Hook into mouse movement for hover effects
        if love and love.mousemoved then
            local original_mousemoved = love.mousemoved or function() end
            love.mousemoved = function(x, y, dx, dy, istouch)
                original_mousemoved(x, y, dx, dy, istouch)
                
                Rhapsody.ui.integration.mouse_x = x
                Rhapsody.ui.integration.mouse_y = y
                
                if Rhapsody.config.ui_open then
                    Rhapsody.ui.update_hover_states(x, y)
                end
            end
        end
        
        print("Rhapsody: UI hooks established")
    end
    
    -- Update hover states for buttons
    function Rhapsody.ui.update_hover_states(mouse_x, mouse_y)
        if Rhapsody.ui.is_on_screen("main") then
            local screen = Rhapsody.ui.screens.main
            Rhapsody.ui.check_button_hover(screen.play_button, mouse_x, mouse_y)
            Rhapsody.ui.check_button_hover(screen.repeat_button, mouse_x, mouse_y)
            Rhapsody.ui.check_button_hover(screen.back_button, mouse_x, mouse_y)
        elseif Rhapsody.ui.is_on_screen("playlist") then
            local screen = Rhapsody.ui.screens.playlist
            Rhapsody.ui.check_button_hover(screen.prev_button, mouse_x, mouse_y)
            Rhapsody.ui.check_button_hover(screen.next_button, mouse_x, mouse_y)
            Rhapsody.ui.check_button_hover(screen.back_button, mouse_x, mouse_y)
            
            -- Check track play buttons
            local tracks = Rhapsody.ui.get_track_page_items()
            for i, track in ipairs(tracks) do
                local panel_data = screen.track_panels[i]
                if panel_data then
                    Rhapsody.ui.check_button_hover(panel_data.play_button, mouse_x, mouse_y)
                end
            end
        elseif Rhapsody.ui.is_on_screen("track_detail") then
            local screen = Rhapsody.ui.screens.track_detail
            Rhapsody.ui.check_button_hover(screen.play_button, mouse_x, mouse_y)
            Rhapsody.ui.check_button_hover(screen.back_button, mouse_x, mouse_y)
        end
    end
    
    -- Joker text integration similar to Partner API
    function Rhapsody.init_joker_text_integration()
        -- Override joker text generation to include music info
        local original_generate_ui = Card.generate_UIBox_ability_table
        
        if original_generate_ui then
            Card.generate_UIBox_ability_table = function(self)
                local ret_table = original_generate_ui(self)
                
                -- Check if this joker has music
                local track = Rhapsody.get_track_for_joker(self.config.center.key)
                if track then
                    -- Add music information to joker text
                    local music_info = {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            minh = 0.4,
                            padding = 0.1,
                            colour = G.C.CLEAR
                        },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {align = "cm"},
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "♪ Now Playing ♪",
                                            colour = G.C.PURPLE,
                                            scale = 0.35,
                                            shadow = true
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {align = "cm"},
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = track.name,
                                            colour = G.C.WHITE,
                                            scale = 0.4,
                                            shadow = true
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = {align = "cm"},
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "by " .. track.author,
                                            colour = G.C.UI.TEXT_LIGHT,
                                            scale = 0.3,
                                            shadow = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    -- Add a separator line
                    table.insert(ret_table, {
                        n = G.UIT.R,
                        config = {align = "cm", minh = 0.1},
                        nodes = {
                            {
                                n = G.UIT.BOX,
                                config = {w = 2, h = 0.02, colour = G.C.PURPLE, r = 0.01}
                            }
                        }
                    })
                    
                    table.insert(ret_table, music_info)
                    
                    -- Add track description if available
                    if track.text and #track.text > 0 then
                        for _, text_line in ipairs(track.text) do
                            table.insert(ret_table, {
                                n = G.UIT.R,
                                config = {align = "cm"},
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = text_line,
                                            colour = G.C.UI.TEXT_LIGHT,
                                            scale = 0.25,
                                            shadow = true
                                        }
                                    }
                                }
                            })
                        end
                    end
                end
                
                return ret_table
            end
        end
        
        print("Rhapsody: Joker text integration initialized")
    end
    
    -- Context-aware music system
    function Rhapsody.init_context_music()
        -- Auto-play music based on visible jokers
        local function check_joker_music()
            if not G or not G.jokers or not G.jokers.cards then return end
            
            for _, card in ipairs(G.jokers.cards) do
                if card.config and card.config.center then
                    local track = Rhapsody.get_track_for_joker(card.config.center.key)
                    if track and not Rhapsody.is_track_playing(track.key) then
                        -- Auto-play joker's theme when joker is visible
                        if Rhapsody.config.auto_play_joker_music then
                            Rhapsody.play_track(track.key)
                            break -- Only play one at a time
                        end
                    end
                end
            end
        end
        
        -- Hook this into game update cycle
        Rhapsody.context_music_timer = 0
        local original_update = Game.update_rhapsody_context or function() end
        Game.update_rhapsody_context = function(dt)
            original_update(dt)
            
            Rhapsody.context_music_timer = Rhapsody.context_music_timer + dt
            if Rhapsody.context_music_timer >= 1.0 then -- Check every second
                check_joker_music()
                Rhapsody.context_music_timer = 0
            end
        end
        
        print("Rhapsody: Context-aware music system initialized")
    end
    
    -- Advanced music visualization effects
    function Rhapsody.create_music_particles_for_joker(joker_card)
        if not joker_card or not joker_card.T or not joker_card.T.x then return end
        
        local x = joker_card.T.x
        local y = joker_card.T.y
        
        -- Create musical note particles around the joker
        for i = 1, 5 do
            local angle = math.random() * math.pi * 2
            local distance = 20 + math.random(30)
            local px = x + math.cos(angle) * distance
            local py = y + math.sin(angle) * distance
            
            Rhapsody.ui.create_music_note_effect(px, py)
        end
    end
    
    -- Enhanced UI effects for special events
    function Rhapsody.create_screen_transition_effect()
        -- Create particle burst effect during screen transitions
        local center_x = Rhapsody.ui.window_width / 2
        local center_y = Rhapsody.ui.window_height / 2
        
        for i = 1, 20 do
            local angle = (i / 20) * math.pi * 2
            local speed = 50 + math.random(100)
            local vx = math.cos(angle) * speed
            local vy = math.sin(angle) * speed
            
            create_particle(
                center_x, center_y,
                vx, vy,
                1.0 + math.random() * 0.5,
                {0.8, 0.2, 0.8, 0.8},
                1 + math.random(2)
            )
        end
    end
    
    -- Cleanup function
    function Rhapsody.cleanup_ui()
        -- Clean up any UI resources
        Rhapsody.ui.components.animations = {}
        Rhapsody.ui.components.particles = {}
        Rhapsody.ui.components.effects = {}
        Rhapsody.ui.components.timers = {}
        
        print("Rhapsody: UI cleaned up")
    end
    
    -- Export UI status for debugging
    function Rhapsody.get_ui_status()
        return {
            initialized = Rhapsody.ui.integration.initialized,
            ui_open = Rhapsody.config.ui_open,
            current_screen = Rhapsody.ui.current_screen,
            animations_active = #Rhapsody.ui.components.animations,
            particles_active = #Rhapsody.ui.components.particles,
            mouse_pos = {Rhapsody.ui.integration.mouse_x, Rhapsody.ui.integration.mouse_y}
        }
    end
end