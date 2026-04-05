local _, Portality = ...
local AddOn = LibStub("AceAddon-3.0"):NewAddon("Portality")

function AddOn:OnInitialize()
    Portality.DB = LibStub("AceDB-3.0"):New("PortalityDB", Portality:GetDefaults())
end

function AddOn:OnEnable()
    Portality:GenerateDropdownData()
    SLASH_PORTALITY1 = "/portality"
    SLASH_PORTALITY2 = "/port"
    SlashCmdList["PORTALITY"] = function() Portality:CreateGUI() end
end

function Portality:ToggleDropdownMenu()
    -- Toggle the dropdown menu. If it's open, close it. If it's closed, open it.
    -- The dropdown should be populated with all active portals (from Data.ChallengeModePortals) and hearthstones (from Data.HearthstoneSpells).
end