-- MapHub v0.3.9 website/help panel, no in-game donation solicitations.
local URL="https://gearhunter.net/addon.php?slug=maphub"
local dialog
local function button(parent,label,x,y,w,h,fn)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetSize(w,h)
    b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    b:SetText(label)
    b:SetScript("OnClick",fn)
    return b
end
local function openSupport()
    if not dialog then
        dialog=CreateFrame("Frame","MapHubWebsiteSupportPanel",UIParent,"BackdropTemplate")
        dialog:SetSize(560,300)
        dialog:SetPoint("CENTER",UIParent,"CENTER",0,0)
        dialog:SetFrameStrata("DIALOG")
        dialog:SetFrameLevel(80)
        dialog:SetMovable(true)
        dialog:EnableMouse(true)
        dialog:RegisterForDrag("LeftButton")
        dialog:SetScript("OnDragStart",dialog.StartMoving)
        dialog:SetScript("OnDragStop",dialog.StopMovingOrSizing)
        dialog:SetClampedToScreen(true)
        dialog:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize=28,insets={left=8,right=8,top=8,bottom=8}})
        local title=dialog:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
        title:SetPoint("TOPLEFT",dialog,"TOPLEFT",25,-21)
        title:SetText("MAPHUB |cffffd18aWEBSITE & SUPPORT|r")
        button(dialog,"X",515,-15,27,24,function() dialog:Hide() end)
        local note=dialog:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        note:SetPoint("TOPLEFT",dialog,"TOPLEFT",27,-64)
        note:SetWidth(502)
        note:SetJustifyH("LEFT")
        note:SetJustifyV("TOP")
        note:SetText("For downloads, releases, setup help, bug reports, and feature requests, visit GearHunter.net. MapHub works without website access.\\n\\n1. Select the link below. 2. Press Ctrl+C. 3. Paste into your web browser outside World of Warcraft.")
        local field=CreateFrame("EditBox",nil,dialog,"InputBoxTemplate")
        field:SetPoint("TOPLEFT",dialog,"TOPLEFT",34,-181)
        field:SetSize(489,28)
        field:SetMaxLetters(200)
        field:SetAutoFocus(false)
        field:SetText(URL)
        field:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
        button(dialog,"SELECT WEBSITE LINK",30,-231,227,31,function()
            field:SetText(URL)
            field:SetFocus()
            field:HighlightText()
        end)
        button(dialog,"CLOSE",335,-231,194,31,function() dialog:Hide() end)
        if UISpecialFrames then table.insert(UISpecialFrames,"MapHubWebsiteSupportPanel") end
        dialog:Hide()
    end
    dialog:Show()
end
MapHubOpenSupport=openSupport
SLASH_MAPHUBSUPPORT1="/mhsupport"
SlashCmdList.MAPHUBSUPPORT=openSupport
local function attachToMainPanel()
    if not MapHubPanel or MapHubPanel.websiteSupportButton then return end
    MapHubPanel.websiteSupportButton=button(MapHubPanel,"Support & Website",250,-42,170,27,openSupport)
end
-- The MapHub main window is created on first /maphub; attach our button when it opens.
if SlashCmdList.MAPHUB then
    local original=SlashCmdList.MAPHUB
    SlashCmdList.MAPHUB=function(...)
        original(...)
        attachToMainPanel()
    end
end
