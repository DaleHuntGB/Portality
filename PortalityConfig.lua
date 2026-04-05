local _, Portality = ...
local AG = LibStub("AceGUI-3.0")
local isGUIOpen = false
local GUIFrame = nil

function Portality:CreateGUI()
    local DB = Portality.DB.global
    if isGUIOpen then return end
    isGUIOpen = true
    GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle("|cFF8080FFPortality|r")
    GUIFrame:SetStatusText("Set Dropdown Keybind in Keybindings Menu")
    GUIFrame:SetLayout("Flow")
    GUIFrame:SetWidth(800)
    GUIFrame:SetHeight(600)
    GUIFrame:SetCallback("OnClose", function() isGUIOpen = false AG:Release(GUIFrame) end)
    GUIFrame:EnableResize(false)
    GUIFrame:Show()

    local KeybindContainer = AG:Create("InlineGroup")
    KeybindContainer:SetLayout("Flow")
    KeybindContainer:SetTitle("Dropdown Menu Keybind")
    KeybindContainer:SetFullWidth(true)
    GUIFrame:AddChild(KeybindContainer)

    local keybindButton = AG:Create("Button")
    keybindButton:SetText("Set Keybind")
    keybindButton:SetFullWidth(true)
    keybindButton:SetText((GetBindingKey("PORTALITY_OPEN") and GetBindingKey("PORTALITY_OPEN") or "None"))
    keybindButton:SetCallback("OnClick", function() Portality.KeybindCaptureFrame:Show() end)
    KeybindContainer:AddChild(keybindButton)

    if not Portality.KeybindCaptureFrame then
        local keybindCaptureFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        keybindCaptureFrame:SetSize(300, 48)
        keybindCaptureFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        keybindCaptureFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, })
        keybindCaptureFrame:SetBackdropColor(0, 0, 0, 0.8)
        keybindCaptureFrame:SetBackdropBorderColor(0, 0, 0, 1)
        keybindCaptureFrame:EnableKeyboard(true)
        keybindCaptureFrame:SetPropagateKeyboardInput(false)
        keybindCaptureFrame:SetScript("OnKeyDown", function(_, key)
            if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then return end

            if key == "ESCAPE" then
                local existing = GetBindingKey("PORTALITY_OPEN")
                if existing then SetBinding(existing, nil) end
            else
                local keyCombo = key
                if IsShiftKeyDown() then keyCombo = "SHIFT-" .. keyCombo end
                if IsControlKeyDown() then keyCombo = "CTRL-" .. keyCombo end
                if IsAltKeyDown() then keyCombo = "ALT-" .. keyCombo end
                SetBinding(keyCombo, "PORTALITY_OPEN")
            end

            SaveBindings(GetCurrentBindingSet())
            keybindCaptureFrame:Hide()
        end)
        keybindCaptureFrame:SetScript("OnHide", function() keybindButton:SetText((GetBindingKey("PORTALITY_OPEN") and GetBindingKey("PORTALITY_OPEN") or "None")) end)

        keybindCaptureFrame:Hide()

        local captureFrameText = keybindCaptureFrame:CreateFontString(nil, "OVERLAY")
        captureFrameText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        captureFrameText:SetPoint("CENTER", keybindCaptureFrame, "CENTER", 0, 0)
        captureFrameText:SetText("Set a Keybind\nPress Escape to Clear")
        captureFrameText:SetJustifyH("CENTER")

        Portality.KeybindCaptureFrame = keybindCaptureFrame
    end

    local function CreateToggleList(parent, dataList, activeTable, isSpell)
        local ScrollContainer = AG:Create("ScrollFrame")
        ScrollContainer:SetLayout("Flow")
        ScrollContainer:SetFullWidth(true)
        ScrollContainer:SetFullHeight(true)
        parent:AddChild(ScrollContainer)

        local InlineGroup = AG:Create("InlineGroup")
        InlineGroup:SetLayout("Flow")
        InlineGroup:SetFullWidth(true)
        ScrollContainer:AddChild(InlineGroup)

        if isSpell then
            for _, expansionPortals in ipairs(dataList) do
                local HasVisiblePortals = false
                for spellID, isAvailable in pairs(expansionPortals) do
                    if isAvailable then
                        if not HasVisiblePortals then
                            local ExpansionHeading = AG:Create("Heading")
                            ExpansionHeading:SetText(Portality.Data.ChallengeModePortalsByExpansion[expansionPortals])
                            ExpansionHeading:SetFullWidth(true)
                            InlineGroup:AddChild(ExpansionHeading)
                            HasVisiblePortals = true
                        end

                        local Toggle = AG:Create("CheckBox")
                        Toggle:SetLabel(Portality:CreateDisplayName(spellID, isSpell))
                        Toggle:SetValue(activeTable[spellID] == true)
                        Toggle:SetRelativeWidth(0.5)
                        Toggle:SetCallback("OnValueChanged", function(_, _, value) activeTable[spellID] = value Portality:GenerateDropdownData() end)
                        Toggle:SetDisabled(not Portality:IsLearnt(spellID, isSpell))
                        InlineGroup:AddChild(Toggle)
                    end
                end
            end
            return
        end

        for itemID in pairs(dataList) do
            local Toggle = AG:Create("CheckBox")
            Toggle:SetLabel(Portality:CreateDisplayName(itemID, isSpell))
            Toggle:SetValue(activeTable[itemID] == true)
            Toggle:SetRelativeWidth(0.5)
            Toggle:SetCallback("OnValueChanged", function(_, _, value) activeTable[itemID] = value Portality:GenerateDropdownData() end)
            Toggle:SetDisabled(not Portality:IsLearnt(itemID, isSpell))
            InlineGroup:AddChild(Toggle)
        end
    end

    local function SelectTabGroup(GUIContainer, _, TabGroup)
        GUIContainer:ReleaseChildren()
        if TabGroup == "ChallengeModePortals" then
            CreateToggleList(GUIContainer, Portality.Data.ChallengeModePortals, DB.ChallengeModePortals, true)
        elseif TabGroup == "Hearthstones" then
            CreateToggleList(GUIContainer, Portality.Data.Hearthstones, DB.Hearthstones, false)
        end
    end

    local TabGroup = AG:Create("TabGroup")
    TabGroup:SetLayout("Flow")
    TabGroup:SetTabs({
        { text = "Challenge Mode Portals", value = "ChallengeModePortals" },
        { text = "Hearthstones", value = "Hearthstones" },
    })
    TabGroup:SetCallback("OnGroupSelected", SelectTabGroup)
    TabGroup:SetFullHeight(true)
    TabGroup:SetFullWidth(true)
    TabGroup:SelectTab("ChallengeModePortals")
    GUIFrame:AddChild(TabGroup)
end
