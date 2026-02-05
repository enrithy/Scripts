local HttpService = cloneref(game:GetService('HttpService'))

local Flags = {}
local Config, Fetcher = {}, {}

local Fluent = loadstring(game:HttpGet('https://raw.githubusercontent.com/enrithy/Scripts/refs/heads/main/Angelwings/interface/shared/interface.luau'))()

if not isfolder('angelwings') then
    makefolder('angelwings')
end

if not isfolder(`angelwings/configs`) then
    makefolder(`angelwings/configs`)
end

if not isfile(`angelwings/configs/{game.GameId}.json`) then
    writefile(`angelwings/configs/{game.GameId}.json`, HttpService:JSONEncode({}))
end

local function save_config()
    for index, value in pairs(Flags) do
        Config[index] = type(value) == 'table' and HttpService:JSONDecode(HttpService:JSONEncode(value)) or value
    end

    pcall(function()
        writefile(`angelwings/configs/{game.GameId}.json`, HttpService:JSONEncode(Config))
    end)
end

local function fetcher_config()
    Fetcher = HttpService:JSONDecode(readfile(`angelwings/configs/{game.GameId}.json`))

    for index, value in pairs(Fetcher) do
        Flags[index] = value
    end

    return Fetcher
end

local Window = Fluent:CreateWindow({
    Title = 'angelwings',
    SubTitle = '',
    TabWidth = 107,
    Size = UDim2.fromOffset(500, 360),
    Acrylic = true,
    Theme = 'Vynixu',
    MinimizeKey = Enum.KeyCode.End
})

if cloneref(game:GetService('UserInputService')).TouchEnabled then
    local mobile_button_ui = Instance.new('ImageButton')
    local mobile_hidden_gui = Instance.new('ScreenGui')

    mobile_hidden_gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
    mobile_hidden_gui.ResetOnSpawn = false

    mobile_button_ui.Position = UDim2.new(0, 50, 0, 50)
    mobile_button_ui.Image = 'rbxassetid://10723346871'
    mobile_button_ui.Size = UDim2.new(0, 44, 0, 44)
    mobile_button_ui.Parent = mobile_hidden_gui
    mobile_button_ui.BackgroundTransparency = 1
    mobile_button_ui.Draggable = true

    mobile_button_ui.MouseButton1Click:Connect(function()
        Window:Minimize()

        if Fluent.Window.Minimized then
            mobile_button_ui.Image = 'rbxassetid://10723346959'
        else
            mobile_button_ui.Image = 'rbxassetid://10723346871'
        end
    end)

    Fluent.GUI.AncestryChanged:Connect(function(_, parent)
        if not parent then
            mobile_hidden_gui:Destroy()
        end
    end)
end

Window.Flags = Flags

local function callback(property, call)
    local Caller = {}

    setmetatable(Caller, {
        __call = function(_, value)
            Flags[property] = value
            save_config()

            return call(value)
        end
    })

    return Caller
end

local function create_signal(signal)
    function signal:create_button(button)
        return signal:CreateButton({
            Title = button.title or '',
            Description = button.description or '',
            Callback = button.callback or (function() end)
        })
    end

    function signal:create_paragraph(paragraph)
        return signal:CreateParagraph({
            Title = paragraph.title or '',
            Content = paragraph.content or ''
        })
    end

    function signal:create_dialog(dialog)
        return Window:Dialog({
            Title = dialog.title or '',
            Content = dialog.content or '',
            Buttons = dialog.buttons or {}
        })
    end

    function signal:create_toggle(connection, toggle)
        toggle.flag = toggle.flag or connection

        toggle.default = toggle.default or false
        toggle.callback = toggle.callback or (function() end)

        if not fetcher_config()[toggle.flag] and not Flags[toggle.flag] then
            Flags[toggle.flag] = toggle.default
        end

        toggle.default = fetcher_config()[toggle.flag] or Flags[toggle.flag]
        toggle.callback = callback(toggle.flag, toggle.callback)

        local INIT = signal:CreateToggle(connection, {
            Title = toggle.title or '',
            Description = toggle.description or '',
            Default = toggle.default,
            flag = toggle.flag,
            Callback = toggle.callback
        })

        function INIT:set_value(value)
            INIT:SetValue(value)
        end

        return INIT
    end

    function signal:create_keybind(connection, keybind)
        keybind.flag = keybind.flag or connection

        keybind.default = keybind.default or 'E'
        keybind.callback = keybind.callback or (function() end)

        if not fetcher_config()[keybind.flag] and not Flags[keybind.flag] then
            Flags[keybind.flag] = keybind.default
        end

        keybind.default = fetcher_config()[keybind.flag] or Flags[keybind.flag]

        local INIT = signal:CreateKeybind(connection, {
            Title = keybind.title or '',
            Description = keybind.description or '',
            Mode = keybind.mode or 'Toggle',
            Default = keybind.default,
            flag = keybind.flag,
            Callback = keybind.callback,
            ChangedCallback = function(value)
                Flags[keybind.flag] = tostring(value):match('Enum%.KeyCode%.(.+)') or value
                save_config()
            end
        })

        function INIT:set_value(value)
            INIT:SetValue(value)
        end

        return INIT
    end

    function signal:create_dropdown(connection, dropdown)
        dropdown.flag = dropdown.flag or connection

        dropdown.options = dropdown.options or {}
        dropdown.multi = dropdown.multi or false
        dropdown.default = dropdown.default or 1
        dropdown.callback = dropdown.callback or (function() end)

        if dropdown.multi and not fetcher_config()[dropdown.flag] and not Flags[dropdown.flag] then
            Flags[dropdown.flag] = {}

            for _, value in pairs(dropdown.options) do
                Flags[dropdown.flag][value] = false
            end
        elseif not fetcher_config()[dropdown.flag] and not Flags[dropdown.flag] then
            Flags[dropdown.flag] = dropdown.default
        end

        dropdown.default = fetcher_config()[dropdown.flag] or Flags[dropdown.flag]
        dropdown.callback = callback(dropdown.flag, dropdown.callback)

        local INIT = signal:CreateDropdown(connection, {
            Title = dropdown.title or '',
            Description = dropdown.description or '',
            Values = dropdown.options,
            Multi = dropdown.multi,
            Default = dropdown.default,
            flag = dropdown.flag,
            Callback = dropdown.callback
        })

        function INIT:set_value(value)
            INIT:SetValue(value)
        end

        return INIT
    end

    function signal:create_slider(connection, slider)
        slider.flag = slider.flag or connection

        slider.default = slider.default or 0
        slider.callback = slider.callback or (function() end)

        if not fetcher_config()[slider.flag] and not Flags[slider.flag] then
            Flags[slider.flag] = slider.default
        end

        slider.default = fetcher_config()[slider.flag] or Flags[slider.flag]
        slider.callback = callback(slider.flag, slider.callback)

        local INIT = signal:CreateSlider(connection, {
            Title = slider.title or '',
            Description = slider.description or '',
            Min = slider.min or 0,
            Max = slider.max or 100,
            Default = slider.default,
            Rounding = slider.rounding or 1,
            flag = slider.flag,
            Callback = slider.callback
        })

        function INIT:set_value(value)
            INIT:SetValue(value)
        end

        return INIT
    end

    function signal:create_input(connection, input)
        input.flag = input.flag or connection

        input.default = input.default or ''
        input.callback = input.callback or (function() end)

        if not fetcher_config()[input.flag] and not Flags[input.flag] then
            Flags[input.flag] = input.default
        end

        input.default = fetcher_config()[input.flag] or Flags[input.flag]
        input.callback = callback(input.flag, input.callback)

        local INIT = signal:CreateInput(connection, {
            Title = input.title or '',
            Description = input.description or '',
            Default = input.default,
            Placeholder = input.place or '',
            Numeric = input.numeric or false,
            Finished = input.finished or false,
            flag = input.flag,
            Callback = input.callback
        })

        function INIT:set_value(value)
            INIT:SetValue(value)
        end

        return INIT
    end

    return signal
end

function Window:create_tab(tab_name, icon)
    local tab = Window:CreateTab({ Title = tab_name, Icon = icon or '' })
    create_signal(tab)

    function tab:create_section(name)
        local section = tab:CreateSection(name)
        create_signal(section)

        return section
    end

    return tab
end

function Window:notify(index)
    Fluent:Notify({
        Title = index.title or Window.Title,
        Content = index.content or '...',
        Duration = index.duration or 3
    })
end

function Window:select_tab(index)
    return Window:SelectTab(index or 1)
end

return Window
