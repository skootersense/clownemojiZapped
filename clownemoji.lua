local version = "1.0.1"
if (not string.find(http.get("https://raw.githubusercontent.com/smdfatnn/clownemojiZapped/main/version", version))) then
    http.download("https://raw.githubusercontent.com/smdfatnn/clownemojiZapped/main/clownemoji.lua", "C:/zapped/lua/clownemoji.lua")
else
    local enableKillsay = gui.add_checkbox("Killsay Enabled")
    local includeTeammates = gui.add_checkbox("On Friendly")
    local filterNames = gui.add_checkbox("Filter Name")
    local messageKillsay = gui.add_textbox("Killsay", "&user& killed by &local& username &username& uid &uid& using &weapon& and was &headshot&")
    local enableNameSpam = gui.add_checkbox("Namespam Enabled", false);
    local name = gui.add_textbox("Namespam", "clownemoji.club");
    local nameSpamSpeed = gui.add_slider("Namespam Interval (ms)", 10, 500, 35);
    local zappedConsoleLogger = gui.add_checkbox("Enable Logging");
    local consoleColor = gui.add_colorpicker("Console Color", color.new(214, 76, 203, 255))
    local crosshairEnabled = gui.add_checkbox("Enable custom crosshair");
    local crosshairColor = gui.add_colorpicker("Crosshair Color", color.new(214, 76, 203, 255));
    local forceWhenUnscoped = gui.add_checkbox("Draw Only On Snipers");
    local crosshairSize = gui.add_slider("Size", 0, 300)
    local crosshairWidth = gui.add_slider("Width", 1, 10)
    local crosshairGap = gui.add_slider("Gap", 0, 300)
    local enableWatermark = gui.add_checkbox("Enable watermark");
    local localPlayer;

    local savedTick = globalvars.curtime;
    local curTick = globalvars.curtime
    local boolSwap = false;
    local nameChanged = 0;
    local currentVersion = "1.0";
    local screenSize = engine.screen_size();
    local watermarkFont = renderer.create_font("Verdana", 12, true);

    utils.log("Clownemoji.club LUA Loaded | Welcome back, " .. zapped.username .. " | Script made by @neplo and @onion \n", color.new(110,221,255));
    utils.event_log("Clownemoji.club LUA Loaded | Welcome back, " .. zapped.username .. " | Script made by @neplo and @onion \n", false);

    function safeGetProp(entity, str, index, custom)
        if (engine.in_game()) then
            if (entity ~= nil and str ~= nil) then
                str = tostring(str)
                if (str ~= "") then
                    if (index == nil) then
                        local prop;
                        if (custom) then
                            prop = entity:get_prop(str);
                        else
                            prop = playerresources.get_prop(entity, str);
                        end
                        if (prop == nil) then return nil; else return prop; end
                    else
                        local prop;
                        if (not custom) then
                            prop = playerresources.get_prop(entity, str, index);
                        end
                        if (prop == nil) then return nil; else return prop; end
                    end
                    return nil;
                end
                return nil;
            end
            return nil;
        end
        return nil;
    end

    function drawText(x, y, text, font, color, style)
        if (x ~= nil and y ~= nil and text ~= nil) then
            text = tostring(text);
            if (color == nil) then color = defaults[1]; end
            if (font == nil) then font = defaults[2]; end

            if (style ~= "c" and style ~= "r" and style ~= "cr") then
                renderer.text(x, y, text, color, font);
            else
                local textSize = renderer.get_text_size(text, font);

                if (style == "c") then
                    renderer.text(x - (textSize.x / 2), y - (textSize.y / 2), text, color, font);
                elseif (style == "r") then
                    renderer.text(x - textSize.x, y, text, color, font);
                else
                    renderer.text(x - textSize.x, y - (textSize.y / 2), text, color, font);
                end
            end
        end
    end

    local function tableContains(table, string)
        for i = 1, #table do
            if (table[i] == string) then
                return true;
            end
        end

        return false;
    end

    function safeSetName(name)
        if (name ~= nil) then
            name = tostring(name)

            if (string.len(name) > 32) then
                name = name:sub(1, 32)
            end

            if (engine.in_game()) then
                utils.set_name(name);
            end
        end
    end

    function safeLog(str, r, g, b, a)
        if (str ~= nil) then
            str = tostring(str)
            if (str ~= "") then
                if (r ~= nil and g ~= nil and b ~= nil and a ~= nil) then
                    local color = color.new(r, g, b, a);
                    if (color ~= nil) then
                        utils.log(str, color);
                    end
                else
                    utils.event_log(str, true);
                end
            end
        end
    end

    function sendMessage(msg)
        if (msg ~= nil) then
            msg = tostring(msg)

            if (string.len(msg) >= 256) then
                msg = msg:sub(1, 256)
            end

            engine.client_cmd("say " .. msg);
        end
    end

    -- Credits Adrian Mole and user973713
    function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end

    function setupString(str, event)
        local entity = entitylist.get_entity_from_userid(event:get_int("userid"));
        local weapon = event:get_string("weapon");
        local headshot = event:get_bool("headshot");

        if (entity ~= nil and localPlayer ~= nil and weapon ~= nil and headshot ~= nil) then
            local table = mysplit(str, "&");
            local endText = "";

            for i = 1, #table do
                if (table[i] == "user") then
                    endText = endText .. entity:get_name();
                elseif (table[i] == "local") then
                    endText = endText .. localPlayer:get_name();
                elseif (table[i] == "weapon") then
                    endText = endText .. weapon;
                elseif (table[i] == "headshot") then
                    if (headshot) then
                        endText = endText .. "headshot";
                    else
                        endText = endText .. "bodyshot";
                    end
                elseif (table[i] == "username") then
                    endText = endText .. zapped.username;
                elseif (table[i] == "uid") then
                    endText = endText .. zapped.userid;
                else
                    endText = endText .. table[i];
                end
            end

            return endText
        else
            safeLog("[Error] - Invalid Entity\n", 255, 0, 0, 255)
            return ""
        end
    end

    function on_gameevent(e)
        if (e:get_name() == "player_death" and enableKillsay:get_value()) then
            local deadEntity = entitylist.get_entity_from_userid(e:get_int("userid"));
            local killerEntity = entitylist.get_entity_from_userid(e:get_int("attacker"));
            localPlayer = entitylist.get_localplayer();
            local color = consoleColor:get_value();
            local r, g, b, a = color.r, color.g, color.b, color.a;

            if (localPlayer ~= nil) then
                if (killerEntity == localPlayer) then
                    if (not deadEntity:is_enemy() and not includeTeammates:get_value()) then return end
                    if (messageKillsay:get_value() == "") then return end
                    local text;

                    if (filterNames:get_value()) then
                        text = setupString(messageKillsay:get_value(), e);
                    else
                        text = messageKillsay:get_value();
                    end

                    sendMessage(text, deadEntity)
                    safeLog("[Message] - " .. text .. "\n", r, g, b, a)
                end
            end

            if(zappedConsoleLogger:get_value()) then
                safeLog("[Event] - " .. e:get_name() .. "\n", r, g, b, a)
                safeLog("[Killer] - " .. entitylist.get_entity_from_userid(e:get_int("attacker")):get_name() .. "\n", r, g, b, a)
                safeLog("[Killed] - " .. entitylist.get_entity_from_userid(e:get_int("userid")):get_name() .. "\n", r, g, b, a)
                safeLog("[Weapon] - " .. e:get_string("weapon") .. "\n", r, g, b, a)
            end
        end
    end

    function on_render()
        if(enableWatermark:get_value()) then
            local text = "clownemoji.club lua | [regular] | version: " .. currentVersion .. " | username: " .. zapped.username .. " | uid: " .. zapped.userid;

            renderer.text(20, 20, text, color.new(255, 255, 255), font);
        end

        if (engine.in_game()) then
            localPlayer = entitylist.get_localplayer();
            curTick = globalvars.curtime;
            if (savedTick > curTick) then
                savedTick = globalvars.curtime;
            end

            if (localPlayer ~= nil) then
                if (nameChanged <= 10) then
                    if (enableNameSpam:get_value()) then
                        if (curTick - savedTick >= nameSpamSpeed:get_value() / 1000) then
                            if (boolSwap) then
                                safeSetName(name:get_value())
                                boolSwap = false;
                            else
                                safeSetName("ß·" .. name:get_value())
                                boolSwap = true;
                            end

                            savedTick = globalvars.curtime;
                            nameChanged = nameChanged + 1;
                        end
                    end
                end
            end

            if(crosshairEnabled:get_value()) then
                local snipers = { "G3SG1", "AWP", "SSG-08", "SCAR-20" }

                local currentWeapon = entitylist.get_player_weapon(localPlayer);
                currentWeapon = currentWeapon:get_name();

                local crosshairClr = crosshairColor:get_value();
                local color2 = crosshairClr;

                local scopedProp = safeGetProp(localPlayer, "m_bIsScoped");
                local rendered = false;

                if (forceWhenUnscoped:get_value() or scopedProp == true) then
                    if (tableContains(snipers, currentWeapon)) then
                        rendered = true;
                    end
                elseif(forceWhenUnscoped:get_value() == false and scopedProp == false) then
                    rendered = true;
                end


                if(rendered) then
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2), (screenSize.y / 2) - (crosshairSize:get_value() + crosshairGap:get_value()), crosshairWidth:get_value(), crosshairSize:get_value(), true, color2, crosshairClr);
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2), (screenSize.y / 2) + crosshairGap:get_value(), crosshairWidth:get_value(), crosshairSize:get_value(), true, crosshairClr, color2);
                    renderer.gradient_rect((screenSize.x / 2) - (crosshairWidth:get_value() / 2) - crosshairSize:get_value() - crosshairGap:get_value(), (screenSize.y / 2) - (crosshairWidth:get_value() / 2), crosshairSize:get_value(), crosshairWidth:get_value(), false, color2, crosshairClr);
                    renderer.gradient_rect((screenSize.x / 2) + (crosshairWidth:get_value() / 2) + crosshairGap:get_value(), (screenSize.y / 2) - (crosshairWidth:get_value() / 2), crosshairSize:get_value(), crosshairWidth:get_value(), false, crosshairClr, color2);
                end
            end
        else
            savedTick = globalvars.curtime;
            curTick = globalvars.curtime;
            nameChanged = 0;
        end
    end
end
