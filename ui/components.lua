-- ui/components.lua
-- Advanced UI components with animations and effects

return function()
    -- Component state tracking
    Rhapsody.ui.components = {
        animations = {},
        particles = {},
        effects = {},
        timers = {}
    }
    
    -- Animation system
    local function create_animation(target, property, start_val, end_val, duration, ease_func)
        local anim = {
            target = target,
            property = property,
            start_val = start_val,
            current_val = start_val,
            end_val = end_val,
            duration = duration,
            elapsed = 0,
            ease_func = ease_func or function(t) return t end, -- Linear by default
            active = true
        }
        
        table.insert(Rhapsody.ui.components.animations, anim)
        return anim
    end
    
    -- Easing functions
    local ease = {
        linear = function(t) return t end,
        quad_in = function(t) return t * t end,
        quad_out = function(t) return 1 - (1 - t) * (1 - t) end,
        cubic_in = function(t) return t * t * t end,
        cubic_out = function(t) return 1 - math.pow(1 - t, 3) end,
        bounce_out = function(t)
            if t < 1/2.75 then
                return 7.5625 * t * t
            elseif t < 2/2.75 then
                t = t - 1.5/2.75
                return 7.5625 * t * t + 0.75
            elseif t < 2.5/2.75 then
                t = t - 2.25/2.75
                return 7.5625 * t * t + 0.9375
            else
                t = t - 2.625/2.75
                return 7.5625 * t * t + 0.984375
            end
        end
    }
    
    -- Particle system for visual effects
    local function create_particle(x, y, vx, vy, life, color, size)
        local particle = {
            x = x,
            y = y,
            vx = vx,
            vy = vy,
            life = life,
            max_life = life,
            color = color or {1, 1, 1, 1},
            size = size or 2,
            active = true
        }
        
        table.insert(Rhapsody.ui.components.particles, particle)
        return particle
    end
    
    -- Update animations and effects
    function Rhapsody.ui.update_components(dt)
        -- Update animations
        for i = #Rhapsody.ui.components.animations, 1, -1 do
            local anim = Rhapsody.ui.components.animations[i]
            if anim.active then
                anim.elapsed = anim.elapsed + dt
                local progress = math.min(anim.elapsed / anim.duration, 1)
                local eased_progress = anim.ease_func(progress)
                
                anim.current_val = anim.start_val + (anim.end_val - anim.start_val) * eased_progress
                anim.target[anim.property] = anim.current_val
                
                if progress >= 1 then
                    anim.active = false
                    table.remove(Rhapsody.ui.components.animations, i)
                end
            end
        end
        
        -- Update particles
        for i = #Rhapsody.ui.components.particles, 1, -1 do
            local particle = Rhapsody.ui.components.particles[i]
            if particle.active then
                particle.x = particle.x + particle.vx * dt
                particle.y = particle.y + particle.vy * dt
                particle.life = particle.life - dt
                
                -- Fade alpha based on remaining life
                particle.color[4] = particle.life / particle.max_life
                
                if particle.life <= 0 then
                    particle.active = false
                    table.remove(Rhapsody.ui.components.particles, i)
                end
            end
        end
    end
    
    -- Advanced UI element creation functions
    function Rhapsody.ui.create_glassmorphism_panel(x, y, w, h, blur_strength)
        return {
            type = "glassmorphism_panel",
            x = x, y = y, w = w, h = h,
            blur_strength = blur_strength or 0.8,
            alpha = 0.15,
            border_alpha = 0.3,
            corner_radius = 12
        }
    end
    
    function Rhapsody.ui.create_animated_button(x, y, w, h, text, callback)
        local button = {
            type = "animated_button",
            x = x, y = y, w = w, h = h,
            text = text,
            callback = callback,
            hover_scale = 1.0,
            pressed_scale = 1.0,
            alpha = 1.0,
            hover_alpha = 1.0,
            pressed = false,
            hovered = false,
            glow_intensity = 0.0
        }
        
        return button
    end
    
    function Rhapsody.ui.create_music_visualizer(x, y, w, h, bars)
        local visualizer = {
            type = "music_visualizer",
            x = x, y = y, w = w, h = h,
            bars = {},
            bar_count = bars or 16,
            max_height = h * 0.8,
            color = {0.8, 0.2, 0.8, 0.9}
        }
        
        -- Initialize bars
        for i = 1, visualizer.bar_count do
            visualizer.bars[i] = {
                height = 0,
                target_height = 0,
                velocity = 0
            }
        end
        
        return visualizer
    end
    
    function Rhapsody.ui.create_progress_ring(x, y, radius, progress, color)
        return {
            type = "progress_ring",
            x = x, y = y,
            radius = radius,
            progress = progress or 0,
            color = color or {0.8, 0.2, 0.8, 1.0},
            thickness = 4,
            glow = true
        }
    end
    
    -- Enhanced text rendering with effects
    function Rhapsody.ui.create_glowing_text(text, x, y, scale, color, glow_color)
        return {
            type = "glowing_text",
            text = text,
            x = x, y = y,
            scale = scale or 1.0,
            color = color or {1, 1, 1, 1},
            glow_color = glow_color or {0.8, 0.2, 0.8, 0.5},
            glow_radius = 3,
            wave_offset = 0
        }
    end
    
    -- Particle effects for interactions
    function Rhapsody.ui.create_button_click_effect(x, y)
        local particle_count = 12
        for i = 1, particle_count do
            local angle = (i / particle_count) * math.pi * 2
            local speed = 100 + math.random(50)
            local vx = math.cos(angle) * speed
            local vy = math.sin(angle) * speed
            
            create_particle(
                x, y,
                vx, vy,
                0.5 + math.random() * 0.3,
                {0.8, 0.2, 0.8, 1.0},
                2 + math.random(2)
            )
        end
    end
    
    function Rhapsody.ui.create_music_note_effect(x, y)
        local notes = {"♪", "♫", "♬", "♩"}
        for i = 1, 3 do
            local note_particle = {
                type = "text_particle",
                x = x + math.random(-20, 20),
                y = y,
                vx = math.random(-30, 30),
                vy = -50 - math.random(30),
                text = notes[math.random(#notes)],
                life = 2.0,
                max_life = 2.0,
                scale = 0.8 + math.random() * 0.4,
                color = {0.8, 0.2, 0.8, 1.0},
                rotation = 0,
                rotation_speed = math.random(-2, 2),
                active = true
            }
            
            table.insert(Rhapsody.ui.components.particles, note_particle)
        end
    end
    
    -- Render functions for components
    function Rhapsody.ui.render_glassmorphism_panel(panel)
        -- This would integrate with the game's rendering system
        -- Placeholder for actual rendering implementation
        print("Rendering glassmorphism panel at " .. panel.x .. "," .. panel.y)
    end
    
    function Rhapsody.ui.render_animated_button(button, dt)
        -- Update button animation state
        local target_scale = button.hovered and 1.05 or 1.0
        if button.pressed then target_scale = 0.95 end
        
        -- Smooth scale transition
        local scale_diff = target_scale - button.hover_scale
        button.hover_scale = button.hover_scale + scale_diff * dt * 8
        
        -- Update glow intensity
        local target_glow = button.hovered and 0.8 or 0.0
        local glow_diff = target_glow - button.glow_intensity
        button.glow_intensity = button.glow_intensity + glow_diff * dt * 6
        
        -- Placeholder for actual rendering
        print("Rendering button: " .. button.text .. " at scale " .. button.hover_scale)
    end
    
    function Rhapsody.ui.render_music_visualizer(visualizer, dt)
        -- Update visualizer bars based on audio data
        for i, bar in ipairs(visualizer.bars) do
            -- Simulate audio data (replace with actual audio analysis)
            local audio_level = math.random() * (Rhapsody.audio.is_playing and 1.0 or 0.1)
            bar.target_height = audio_level * visualizer.max_height
            
            -- Spring physics for smooth bar movement
            local spring_force = (bar.target_height - bar.height) * 15
            local damping = bar.velocity * 8
            bar.velocity = bar.velocity + (spring_force - damping) * dt
            bar.height = bar.height + bar.velocity * dt
            
            -- Clamp values
            bar.height = math.max(0, math.min(visualizer.max_height, bar.height))
        end
        
        print("Rendering music visualizer with " .. #visualizer.bars .. " bars")
    end
    
    function Rhapsody.ui.render_progress_ring(ring)
        -- Placeholder for circular progress rendering
        print("Rendering progress ring: " .. (ring.progress * 100) .. "%")
    end
    
    function Rhapsody.ui.render_particles()
        for _, particle in ipairs(Rhapsody.ui.components.particles) do
            if particle.active then
                if particle.type == "text_particle" then
                    particle.rotation = particle.rotation + particle.rotation_speed * dt
                    print("Rendering text particle: " .. particle.text)
                else
                    print("Rendering particle at " .. particle.x .. "," .. particle.y)
                end
            end
        end
    end
    
    -- Component interaction system
    function Rhapsody.ui.check_button_hover(button, mouse_x, mouse_y)
        local in_bounds = mouse_x >= button.x and mouse_x <= button.x + button.w and
                         mouse_y >= button.y and mouse_y <= button.y + button.h
        
        if in_bounds and not button.hovered then
            button.hovered = true
            -- Create hover effect
            create_particle(
                button.x + button.w/2, button.y + button.h/2,
                0, 0, 0.3,
                {0.8, 0.2, 0.8, 0.5}, 1
            )
        elseif not in_bounds and button.hovered then
            button.hovered = false
        end
        
        return in_bounds
    end
    
    function Rhapsody.ui.handle_button_click(button, mouse_x, mouse_y)
        if Rhapsody.ui.check_button_hover(button, mouse_x, mouse_y) then
            button.pressed = true
            Rhapsody.ui.create_button_click_effect(mouse_x, mouse_y)
            
            if button.callback then
                button.callback()
            end
            
            -- Reset pressed state after a short delay
            Rhapsody.ui.components.timers[#Rhapsody.ui.components.timers + 1] = {
                time = 0.1,
                callback = function() button.pressed = false end
            }
            
            return true
        end
        return false
    end
    
    -- Timer system for delayed callbacks
    function Rhapsody.ui.update_timers(dt)
        for i = #Rhapsody.ui.components.timers, 1, -1 do
            local timer = Rhapsody.ui.components.timers[i]
            timer.time = timer.time - dt
            
            if timer.time <= 0 then
                if timer.callback then
                    timer.callback()
                end
                table.remove(Rhapsody.ui.components.timers, i)
            end
        end
    end
    
    -- Master update function for all components
    function Rhapsody.ui.update_all_components(dt)
        Rhapsody.ui.update_components(dt)
        Rhapsody.ui.update_timers(dt)
    end
end