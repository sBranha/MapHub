local addon = CreateFrame('Frame')
local panel, guide, listButtons
local entries = {
 {id='starter', title='How to use Map Hub', category='Secrets', mapID=nil, steps={
  'Open the world map with M. Open Map Hub using /maphub.',
  'Choose a guide. If a step has coordinates, click Guide Me to set a map waypoint.',
  'Check off steps as you complete them. Progress is saved for your character.',
  'New verified treasure and profession guides can be added in future data packs.'}},
 {id='tailoring', title='Tailoring recipe checklist', category='Tailoring', steps={
  'Open your Tailoring profession window and check which recipes you have not learned.',
  'Check your profession specialization and unspent knowledge points.',
  'Visit a Tailoring trainer and inspect recipes available from the trainer.',
  'Check profession vendors, crafting orders, and reputation rewards for missing recipes.'}},
 {id='leatherworking', title='Leatherworking knowledge checklist', category='Leatherworking', steps={
  'Open Leatherworking and inspect your specialization trees.',
  'Check available first-craft knowledge and profession quests.',
  'Look for expansion-specific profession knowledge treasures in verified guides.',
  'Spend points deliberately; this addon does not change your specialization.'}},
 {id='treasure', title='Multi-NPC treasure walkthrough template', category='Treasures', steps={
  'Read the chest tooltip or clue to identify prerequisites.',
  'Find the first required NPC and complete their dialogue.',
  'Visit the remaining NPCs in the required order.',
  'Return to the chest and open it.'}},
}
local function charKey() return (UnitName('player') or 'Unknown')..'-'..(GetRealmName() or 'Realm') end
local function store()
 MapHubDB = MapHubDB or {characters={}}
 local k=charKey(); MapHubDB.characters[k]=MapHubDB.characters[k] or {}
 return MapHubDB.characters[k]
end
local function button(parent, label, x,y,w,h,fn)
 local b=CreateFrame('Button',nil,parent,'UIPanelButtonTemplate'); b:SetSize(w,h); b:SetPoint('TOPLEFT',x,y); b:SetText(label); b:SetScript('OnClick',fn); return b
end
local function waypoint(step)
 if not step.mapID or not step.x or not step.y then
  print('|cffffcc66Map Hub:|r No verified coordinates are supplied for this step yet.'); return
 end
 if not (C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(step.mapID)) then
  print('|cffffcc66Map Hub:|r Cannot set a waypoint on this map.'); return
 end
 local point=UiMapPoint.CreateFromCoordinates(step.mapID,step.x/100,step.y/100)
 if C_Map.SetUserWaypoint(point) then
  if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
  print('|cff70d6a0Map Hub:|r Waypoint set.')
 end
end
local function showEntry(entry)
 local data=store(); data[entry.id]=data[entry.id] or {}; local progress=data[entry.id]
 guide.title:SetText(entry.title)
 for _,w in ipairs(guide.rows) do w:Hide() end
 for i,step in ipairs(entry.steps) do
  local row=guide.rows[i]
  if not row then
   row=CreateFrame('Frame',nil,guide); row:SetSize(365,58)
   row.check=CreateFrame('CheckButton',nil,row,'UICheckButtonTemplate'); row.check:SetPoint('TOPLEFT',0,-3)
   row.text=row:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall'); row.text:SetPoint('TOPLEFT',36,-7); row.text:SetWidth(305); row.text:SetJustifyH('LEFT'); row.text:SetWordWrap(true)
   row.go=button(row,'Guide Me',36,-32,92,21,function() waypoint(row.step) end)
   guide.rows[i]=row
  end
  row:SetPoint('TOPLEFT',14,-58-(i-1)*63)
  local label=type(step)=='table' and step.text or step
  row.step=type(step)=='table' and step or {}
  row.text:SetText(i..'. '..label)
  row.check:SetChecked(progress[i] == true)
  row.check:SetScript('OnClick',function(self) progress[i]=self:GetChecked() and true or nil end)
  if row.step.mapID and row.step.x and row.step.y then row.go:Enable() else row.go:Disable() end
  row:Show()
 end
 guide:Show()
end
local function createUI()
 panel=CreateFrame('Frame','MapHubPanel',UIParent,'BackdropTemplate'); panel:SetSize(620,420); panel:SetPoint('CENTER'); panel:SetFrameStrata('DIALOG'); panel:SetMovable(true); panel:EnableMouse(true); panel:RegisterForDrag('LeftButton'); panel:SetScript('OnDragStart',panel.StartMoving); panel:SetScript('OnDragStop',panel.StopMovingOrSizing)
 panel:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',edgeSize=28,insets={left=8,right=8,top=8,bottom=8}})
 local heading=panel:CreateFontString(nil,'OVERLAY','GameFontNormalLarge'); heading:SetPoint('TOPLEFT',20,-18); heading:SetText('|cffffd18aMAP HUB|r  |cff9db2c5v0.3.7|r')
 button(panel,'X',574,-14,26,24,function() panel:Hide() end)
 local sub=panel:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall'); sub:SetPoint('TOPLEFT',20,-47); sub:SetText('Treasure guides  •  Secrets  •  Profession checklists')
 button(panel,'Farming Finder',430,-42,170,27,function() if MapHubOpenFarming then MapHubOpenFarming() end end)
 local left=CreateFrame('Frame',nil,panel,'BackdropTemplate'); left:SetSize(205,335); left:SetPoint('TOPLEFT',15,-76); left:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'}); left:SetBackdropColor(.05,.09,.14,.8)
 guide=CreateFrame('Frame',nil,panel,'BackdropTemplate'); guide:SetSize(374,335); guide:SetPoint('TOPLEFT',228,-76); guide:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'}); guide:SetBackdropColor(.08,.11,.15,.8)
 guide.title=guide:CreateFontString(nil,'OVERLAY','GameFontNormal'); guide.title:SetPoint('TOPLEFT',14,-18); guide.title:SetWidth(340); guide.title:SetJustifyH('LEFT'); guide.rows={}
 for i,entry in ipairs(entries) do
  local b=button(left,entry.title,8,-10-(i-1)*54,188,48,function() showEntry(entry) end)
  b:GetFontString():SetFontObject('GameFontHighlightSmall')
 end
 panel:Hide(); showEntry(entries[1])
end
SLASH_MAPHUB1='/maphub'; SlashCmdList.MAPHUB=function() if not panel then createUI() end if panel:IsShown() then panel:Hide() else panel:Show() end end
addon:RegisterEvent('PLAYER_LOGIN'); addon:SetScript('OnEvent',function() store(); print('|cffd8b56aMap Hub|r loaded. Type /maphub to open.') end)