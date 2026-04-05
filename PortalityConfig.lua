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

    local function CreateToggleList(parent, dataList, activeTable, isSpell)
        local ScrollContainer = AG:Create("ScrollFrame")
        ScrollContainer:SetLayout("Flow")
        ScrollContainer:SetFullWidth(true)
        ScrollContainer:SetFullHeight(true)
        parent:AddChild(ScrollContainer)

        if isSpell then
            for _, expansionPortals in ipairs(dataList) do
                local HasVisiblePortals = false
                for spellID, isAvailable in pairs(expansionPortals) do
                    if isAvailable then
                        if not HasVisiblePortals then
                            local ExpansionHeading = AG:Create("Heading")
                            ExpansionHeading:SetText(Portality.Data.ChallengeModePortalsByExpansion[expansionPortals])
                            ExpansionHeading:SetFullWidth(true)
                            ScrollContainer:AddChild(ExpansionHeading)
                            HasVisiblePortals = true
                        end

                        local Toggle = AG:Create("CheckBox")
                        Toggle:SetLabel(Portality:CreateDisplayName(spellID, isSpell))
                        Toggle:SetValue(activeTable[spellID] == true)
                        Toggle:SetRelativeWidth(0.33)
                        Toggle:SetCallback("OnValueChanged", function(_, _, value) activeTable[spellID] = value Portality:GenerateDropdownData() end)
                        Toggle:SetDisabled(not Portality:IsLearnt(spellID, isSpell))
                        ScrollContainer:AddChild(Toggle)
                    end
                end
            end
            return
        end

        for itemID in pairs(dataList) do
            local Toggle = AG:Create("CheckBox")
            Toggle:SetLabel(Portality:CreateDisplayName(itemID, isSpell))
            Toggle:SetValue(activeTable[itemID] == true)
            Toggle:SetRelativeWidth(0.33)
            Toggle:SetCallback("OnValueChanged", function(_, _, value) activeTable[itemID] = value Portality:GenerateDropdownData() end)
            Toggle:SetDisabled(not Portality:IsLearnt(itemID, isSpell))
            ScrollContainer:AddChild(Toggle)
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
