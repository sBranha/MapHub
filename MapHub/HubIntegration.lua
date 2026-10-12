-- Optional website integration: independent addon; no companion required to run.
local frame=CreateFrame('Frame')
frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent',function()
    if type(GearHubBridge_RecordLoad)=='function' then GearHubBridge_RecordLoad('maphub','0.3.7') end
end)
SLASH_MAPHUBWEBSITE1='/maphubsite'
SlashCmdList.MAPHUBWEBSITE=function() print('|cffdfbc70MapHub:|r Downloads, updates and support: https://gearhunter.net/addon.php?slug=maphub') end
