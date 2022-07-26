local wibox = require "wibox"
local awful = require "awful"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local images = require "images"

--local iconsdir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"
--local mat_icons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local recycler = require "lib.awesome-widgets.recycler"

local function cross_enter (self, _)
    --self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
end
local function cross_leave (self, _)
    --self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
end
local notifications

notifications = recycler(
    function()
        local w

        w = wibox.widget {
            widget = wibox.container.background,
            bg = beautiful.bg_focus,
            shape = beautiful.theme_shape,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_focus_dark,
                    {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            layout = wibox.layout.fixed.horizontal,
                            {
                                id = 'title',
                                widget = wibox.widget.textbox,
                                font = "12",
                                --text = n.title
                            },
                            {
                                widget = wibox.container.place,
                                fill_horizontal = true,
                                halign = 'right',
                                valign = 'center',
                                {
                                    id = 'remove',
                                    widget = wibox.widget.imagebox,
                                    image = images.drag, --gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal),
                                    forced_height = 24,
                                    forced_width = 24,
                                    --buttons =
                                }
                            }
                        }
                    }
                },
                {
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        layout = wibox.layout.fixed.horizontal,
                        {
                            widget = wibox.container.margin,
                            margins = dpi(5),
                            {
                                id = 'icon',
                                widget = wibox.widget.imagebox,
--                                image = n.icon,
                                resize = true,
                                forced_width = 0,
                                forced_height = 0,
                                clip_shape = beautiful.theme_shape
                            }
                        },
                        {
                            id = 'text',
                            widget = wibox.widget.textbox,
                            font = "12", 
--                            text = n.message
                        }
                    }
                }
            }
        }
        function w:populate(n)
            --w:get_children_by_id('remove')[1]:connect_signal("mouse::enter", function() cross_enter(w) end)
            --w:get_children_by_id('remove')[1]:connect_signal("mouse::leave", function() cross_leave(w) end)
            w:get_children_by_id('title')[1].text = n.title
            w:get_children_by_id('text')[1].text = n.message
            w:get_children_by_id('icon')[1]:set_image(n.icon)
            w:get_children_by_id('icon')[1].forced_height = dpi(40)
            w:get_children_by_id('icon')[1].forced_width = dpi(40)
            w:get_children_by_id('remove')[1]:add_button(
                awful.button {
                    modifiers = {},
                        button = 1,
                        on_press = function ()
                            w:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                            w:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                            notifications:remove(w)
                            collectgarbage("collect")
                            end
                }
            )
        end
        return w
    end,
    {}
)


--[[ wibox.widget {
    layout = recycler,
    spacing = dpi(5)
}]]
local notifbox = wibox.widget { --empty because it will be filled with the update function
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
        widget = wibox.container.background,
        bg = beautiful.bg_focus_dark,
        shape = beautiful.theme_shape,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.widget.textbox,
                    text = "clear all",
                    font = "13"
                },
                {
                    id = 'clear_button',
                    widget = wibox.container.place,
                    valign = 'center',
                    halign = 'right',
                    fill_horizontal = true,
                    {
                        widget = wibox.widget.imagebox,
                        image = images.drag, --gears.color.recolor_image(mat_icons .. "clear_all.svg", beautiful.fg_focus),
                        resize = true,
                        forced_height = 24,
                        forced_width = 24,
                    },
                    buttons = awful.button {
                        modifiers = {},
                        button = 1,
                        on_press = function ()
                            --notifications:reset()
                            notifications:set_children() --clears
                        end
                    }
                }
            }
        }
    },
    notifications
}
--require "helpers".pointer_on_focus(notifbox:get_children_by_id('clear_button')[1])

local function add_notif (n)
    if n.app_name ~= 'Spotify' then --ignore spotify notifications
        notifications:add_at(1,n)
--[[        local self
        local function cross_enter ()
            self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
        end
        local function cross_leave ()
            self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
        end
        self = wibox.widget {
            widget = wibox.container.background,
            bg = beautiful.bg_focus,
            shape = beautiful.theme_shape,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_focus_dark,
                    {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            layout = wibox.layout.fixed.horizontal,
                            {
                                widget = wibox.widget.textbox,
                                font = beautiful.font_bold .. " 12",
                                text = n.title
                            },
                            {
                                widget = wibox.container.place,
                                fill_horizontal = true,
                                halign = 'right',
                                valign = 'center',
                                {
                                    id = 'remove',
                                    widget = wibox.widget.imagebox,
                                    image = gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal),
                                    forced_height = beautiful.get_font_height(beautiful.font_bold .. " 12")*(2/3),
                                    forced_width = beautiful.get_font_height(beautiful.font_bold .. " 12"),
                                    buttons = awful.button {
                                        modifiers = {},
                                        button = 1,
                                        on_press = function ()
                                            self:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                                            self:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                                            notifications:remove_widgets(self)
                                            self = nil
                                            collectgarbage("collect")
                                        end
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        layout = wibox.layout.fixed.horizontal,
                        n.icon ~= nil and {
                            widget = wibox.container.margin,
                            margins = dpi(5),
                            {
                                id = 'icon',
                                widget = wibox.widget.imagebox,
                                image = n.icon,
                                resize = true,
                                forced_width = dpi(40),
                                forced_height = dpi(40),
                                clip_shape = beautiful.theme_shape
                            }
                        },
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font_thin .. " 10",
                            text = n.message
                        }
                    }
                }
            }
        }
        self:get_children_by_id('remove')[1]:connect_signal("mouse::enter", cross_enter)
        self:get_children_by_id('remove')[1]:connect_signal("mouse::leave", cross_leave)

        --always insert at the top of the widget
        --]]
       -- notifications:insert(1,self)
    end
end

naughty.connect_signal("request::display", function(n)
    add_notif(n)
end)

return notifbox
