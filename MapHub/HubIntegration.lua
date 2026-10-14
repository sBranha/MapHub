-- MapHub website integration: independent addon, no HTTP or browser access inside WoW.
local frame=CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent",function()
    if type(GearHubBridge_RecordLoad)=="function" then GearHubBridge_RecordLoad("maphub","0.3.9") end
end)
SLASH_MAPHUBWEBSITE1="/maphubsite"
SlashCmdList.MAPHUBWEBSITE=function()
    print("|cffdfbc70MapHub:|r Downloads, updates and support: https://gearhunter.net/addon.php?slug=maphub")
    print("|cff93c5fdMapHub:|r To copy the address use /mhsupport or Support & Website in /maphub.")
end
