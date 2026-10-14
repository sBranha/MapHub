-- Map Hub v0.3.9: automatic verified pins on the Blizzard world map.
local function settings()
 MapHubDB=MapHubDB or {}
 MapHubDB.mapPinFilters=MapHubDB.mapPinFilters or {}
 MapHubDB.completedPins=MapHubDB.completedPins or {}
 if MapHubDB.hideCollected==nil then MapHubDB.hideCollected=false end
 return MapHubDB
end
local function key(r)
 return tostring(r.mapID)..':'..r.category..':'..r.name
end
local function completed(r)
 local db=settings()
 if r.questID and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
  local ok,result=pcall(C_QuestLog.IsQuestFlaggedCompleted,r.questID)
  if ok and result then return true end
 end
 return db.completedPins[key(r)]==true
end
local function refresh()
 if WorldMapFrame and WorldMapFrame.MapHubProvider then
  WorldMapFrame.MapHubProvider:RefreshAllData()
 end
end
local provider = CreateFromMixins(MapCanvasDataProviderMixin)
local function waypoint(r)
 if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates) then return end
 if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(r.mapID) then
  print('Map Hub: Blizzard does not allow a waypoint on this map.'); return
 end
 C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(r.mapID,r.x/100,r.y/100))
 if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
 print(('Map Hub: Tracking %s (%.1f, %.1f)'):format(r.name,r.x,r.y))
end
MapHubPinMixin = CreateFromMixins(MapCanvasPinMixin)
function MapHubPinMixin:OnLoad()
 self:UseFrameLevelType('PIN_FRAME_LEVEL_AREA_POI')
 self:SetSize(23,23)
 self:EnableMouse(true)
 self:SetScript("OnMouseUp", function(pin, button) pin:OnClick(button) end)
end
function MapHubPinMixin:OnAcquired(r)
 self.record=r
 self:SetPosition(r.x/100,r.y/100)
 self.Icon:SetTexture('Interface\\MINIMAP\\POIIcons')
 -- Blizzard's built-in POI sprite sheet: distinct visual treatment per category.
 if r.category=='Rare' then
  self.Icon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_8')
  self.Icon:SetTexCoord(0,1,0,1)
  self.Icon:SetVertexColor(1,.35,.35,1)
 elseif r.category=='Secret' then
  self.Icon:SetTexture('Interface\\Icons\\INV_Misc_Key_03')
  self.Icon:SetTexCoord(0,1,0,1)
  self.Icon:SetVertexColor(1,1,1,1)
 else
  self.Icon:SetTexture('Interface\\Icons\\INV_Misc_TreasureChest02b')
  self.Icon:SetTexCoord(0,1,0,1)
  self.Icon:SetVertexColor(1,1,1,1)
 end
 if completed(r) then self.Icon:SetVertexColor(.48,.48,.48,.75) end
end
function MapHubPinMixin:OnMouseEnter()
 if not self.record then return end
 GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
 GameTooltip:AddLine(self.record.name,1,.82,.2)
 GameTooltip:AddLine(self.record.category..' | Left-click: waypoint',.75,.85,1)
 GameTooltip:AddLine('Right-click: mark collected / uncollected',.75,.85,1)
 if completed(self.record) then GameTooltip:AddLine('Collected / completed',.4,1,.5) end
 GameTooltip:AddLine(('Coordinates: %.1f, %.1f'):format(self.record.x,self.record.y),1,1,1)
 if self.record.description then GameTooltip:AddLine(self.record.description,1,1,1,true) end
 GameTooltip:Show()
end
function MapHubPinMixin:OnMouseLeave() GameTooltip:Hide() end
function MapHubPinMixin:OnClick(button)
 if not self.record then return end
 if button=='LeftButton' then waypoint(self.record)
 elseif button=='RightButton' then
  local db=settings()
  db.completedPins[key(self.record)]=not completed(self.record)
  GameTooltip:Hide()
  refresh()
 end
end
function provider:RemoveAllData() self:GetMap():RemoveAllPinsByTemplate('MapHubLocationPinTemplate') end
function provider:RefreshAllData()
 self:RemoveAllData()
 local db=settings()
 local mapID=self:GetMap():GetMapID()
 if not mapID then return end
 for _,r in ipairs(MapHubMapRecords or {}) do
  if r.mapID==mapID and db.mapPinFilters[r.category]~=false and (not db.hideCollected or not completed(r)) then
   local ok,err=pcall(self.GetMap(self).AcquirePin,self:GetMap(),'MapHubLocationPinTemplate',r)
   if not ok then print('Map Hub pin error: '..tostring(err)); break end
  end
 end
end
local function makeFilters()
 if WorldMapFrame.MapHubFilterPanel then
  local p=WorldMapFrame.MapHubFilterPanel
  p:SetShown(not p:IsShown()); return
 end
 local p=CreateFrame('Frame',nil,WorldMapFrame,'BackdropTemplate')
 p:SetSize(240,332)
 p:SetPoint('TOPRIGHT',WorldMapFrame,'TOPRIGHT',-12,-92)
 p:SetFrameStrata('DIALOG')
 p:SetFrameLevel(WorldMapFrame:GetFrameLevel()+30)
 p:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=14,insets={left=3,right=3,top=3,bottom=3}})
 local title=p:CreateFontString(nil,'OVERLAY','GameFontNormal')
 title:SetPoint('TOPLEFT',p,'TOPLEFT',12,-12);title:SetText('Map Hub Filters')
 local close=CreateFrame('Button',nil,p,'UIPanelCloseButton')
 close:SetPoint('TOPRIGHT',p,'TOPRIGHT',2,2)
 local entries={{'Rare','Show Rares'},{'Treasure','Show Treasures'},{'Chest','Show Chests'},{'Secret','Show Secrets'},{'Collectible','Show Collectibles'},{'Profession','Show Profession'},{'Gathering','Show Gathering'},{'Other','Show Other'}}
 for i,e in ipairs(entries) do
  local category,label=e[1],e[2]
  local cb=CreateFrame('CheckButton',nil,p,'UICheckButtonTemplate')
  cb:SetPoint('TOPLEFT',p,'TOPLEFT',12,-25-i*26)
  cb.text:SetText(label)
  cb:SetChecked(settings().mapPinFilters[category]~=false)
  cb:SetScript('OnClick',function(self) settings().mapPinFilters[category]=self:GetChecked() and true or false;refresh() end)
 end
 local hide=CreateFrame('CheckButton',nil,p,'UICheckButtonTemplate')
 hide:SetPoint('TOPLEFT',p,'TOPLEFT',12,-249)
 hide.text:SetText('Hide Already Collected')
 hide:SetChecked(settings().hideCollected)
 hide:SetScript('OnClick',function(self) settings().hideCollected=self:GetChecked() and true or false;refresh() end)
 local show=CreateFrame('Button',nil,p,'UIPanelButtonTemplate')
 show:SetPoint('TOPLEFT',p,'TOPLEFT',12,-283)
 show:SetSize(215,25)
 show:SetText('Show All Locations')
 show:SetScript('OnClick',function() settings().mapPinFilters={};settings().hideCollected=false;p:Hide();refresh() end)
 WorldMapFrame.MapHubFilterPanel=p
end
local function install()
 if not WorldMapFrame then return end
 if not MapCanvasDataProviderMixin or not MapCanvasPinMixin then print('Map Hub: Blizzard map components unavailable.'); return end
 if not WorldMapFrame.MapHubButton then
  local b=CreateFrame('Button',nil,WorldMapFrame,'UIPanelButtonTemplate')
  b:SetSize(105,25); b:SetText('Map Hub')
  b:SetPoint('TOPRIGHT',WorldMapFrame,'TOPRIGHT',-75,-32)
  b:SetFrameLevel(WorldMapFrame:GetFrameLevel()+15)
  b:SetScript('OnClick',function() if MapHubOpenExplorer then MapHubOpenExplorer() end end)
  WorldMapFrame.MapHubButton=b
 end
 if not WorldMapFrame.MapHubFiltersButton then
  local f=CreateFrame('Button',nil,WorldMapFrame,'UIPanelButtonTemplate')
  f:SetSize(75,25);f:SetText('Filters')
  f:SetPoint('RIGHT',WorldMapFrame.MapHubButton,'LEFT',-5,0)
  f:SetFrameLevel(WorldMapFrame:GetFrameLevel()+15)
  f:SetScript('OnClick',makeFilters)
  WorldMapFrame.MapHubFiltersButton=f
 end
 if not WorldMapFrame.MapHubProvider then
  local ok,err=pcall(WorldMapFrame.AddDataProvider,WorldMapFrame,provider)
  if ok then WorldMapFrame.MapHubProvider=provider else print('Map Hub provider error: '..tostring(err)) end
 end
end
local loader=CreateFrame('Frame')
loader:RegisterEvent('PLAYER_LOGIN')
loader:RegisterEvent('ADDON_LOADED')
loader:SetScript('OnEvent',function(_,event,name) if event=='PLAYER_LOGIN' or (event=='ADDON_LOADED' and name=='Blizzard_WorldMap') then install() end end)
if WorldMapFrame then install() end
SLASH_MAPHUBPINS1='/mhpins'
SlashCmdList.MAPHUBPINS=function()
 install()
 if provider:GetMap() then provider:RefreshAllData() end
 local id=WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
 local count=0
 for _,r in ipairs(MapHubMapRecords or {}) do if r.mapID==id then count=count+1 end end
 print(('Map Hub 0.3.9: map ID %s; %d markers for this map; %d total records.'):format(tostring(id),count,#(MapHubMapRecords or {})))
 if count==0 then print('Map Hub: No records for this map. Midnight Eversong map ID 2395; old Eversong is a different map.') end
end