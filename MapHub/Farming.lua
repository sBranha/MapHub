-- Map Hub farming finder 0.2.0. Curated starter locations, not a complete database.
local spots = {
 {name='Felcloth - Jadefire Run', expansion='Classic', kind='Cloth', zone='Felwood', map=77, x=43, y=20, mob='Jadefire satyrs', note='Classic-era location. Farm the northern Jadefire camp. Retail drops may differ.'},
 {name='Felcloth - Legashi Encampment', expansion='Classic', kind='Cloth', zone='Azshara', map=76, x=52, y=19, mob='Legashi satyrs', note='Classic-era location. The satyr camps were changed in Retail; verify game version.'},
 {name='Felcloth - Dire Maul East', expansion='Classic', kind='Cloth', zone='Feralas', map=69, x=59, y=45, mob='Wildspawn satyrs (inside dungeon)', note='Dungeon option. Waypoint is an approximate zone destination, not an indoor dungeon marker.'},
 {name='Mageweave - Dunemaul Compound', expansion='Classic', kind='Cloth', zone='Tanaris', map=71, x=43, y=56, mob='Dunemaul ogres', note='Classic-era humanoid cloth farm; yield varies by game edition.'},
 {name='Mageweave - Deadwood Village', expansion='Classic', kind='Cloth', zone='Felwood', map=77, x=49, y=89, mob='Deadwood furbolgs', note='Classic-era alternative. Reputation effects may matter.'},
}
local expansions={'All','Classic','The Burning Crusade','Wrath of the Lich King','Cataclysm','Mists of Pandaria','Warlords of Draenor','Legion','Battle for Azeroth','Shadowlands','Dragonflight','The War Within','Midnight'}
local kinds={'All','Cloth','Skinning','Herbalism','Mining','Other'}
local frame, results, selected, expIndex, kindIndex = nil, {}, nil, 1, 1
local function btn(parent,label,x,y,w,h,fn)
 local b=CreateFrame('Button',nil,parent,'UIPanelButtonTemplate'); b:SetSize(w,h); b:SetPoint('TOPLEFT',x,y); b:SetText(label); b:SetScript('OnClick',fn); return b
end
local function navigate(spot)
 if not spot then return end
 if WorldMapFrame and WorldMapFrame.SetMapID then WorldMapFrame:SetMapID(spot.map); WorldMapFrame:Show() end
 if not (C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(spot.map) and UiMapPoint) then
  print('|cffffcc66Map Hub:|r Open '..spot.zone..' ('..spot.x..', '..spot.y..'). Waypoint API unavailable.'); return
 end
 local p=UiMapPoint.CreateFromCoordinates(spot.map,spot.x/100,spot.y/100)
 C_Map.SetUserWaypoint(p)
 if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
 print('|cff70d6a0Map Hub:|r '..spot.name..' at '..spot.zone..' '..spot.x..', '..spot.y)
end
local function refresh()
 if not frame then return end
 frame.exp:SetText('Expansion: '..expansions[expIndex]..'  >')
 frame.kind:SetText('Category: '..kinds[kindIndex]..'  >')
 local q=string.lower(frame.search:GetText() or '')
 local matches={}
 for _,spot in ipairs(spots) do
  if (expIndex==1 or spot.expansion==expansions[expIndex]) and (kindIndex==1 or spot.kind==kinds[kindIndex]) and (q=='' or string.find(string.lower(spot.name..' '..spot.zone..' '..spot.mob),q,1,true)) then table.insert(matches,spot) end
 end
 for i,b in ipairs(results) do
  local s=matches[i]; b.spot=s
  if s then b:SetText(s.name); b:Show() else b:Hide() end
 end
 frame.count:SetText(#matches..' verified starter entries')
 if #matches==0 then frame.detail:SetText('No verified locations in this starter database for these filters. More expansion-specific spots need research and testing.'); selected=nil
 else selected=matches[1]; frame.detail:SetText(selected.zone..' ('..selected.x..', '..selected.y..')\nTarget: '..selected.mob..'\n\n'..selected.note) end
end
local function create()
 frame=CreateFrame('Frame','MapHubFarmingPanel',UIParent,'BackdropTemplate'); frame:SetSize(650,455); frame:SetPoint('CENTER'); frame:SetFrameStrata('DIALOG'); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag('LeftButton'); frame:SetScript('OnDragStart',frame.StartMoving); frame:SetScript('OnDragStop',frame.StopMovingOrSizing)
 frame:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',edgeSize=28,insets={left=8,right=8,top=8}})
 local title=frame:CreateFontString(nil,'OVERLAY','GameFontNormalLarge'); title:SetPoint('TOPLEFT',20,-18); title:SetText('MAP HUB  |cff9db2c5v0.3.9|r  - Farming Finder')
 btn(frame,'X',605,-12,26,25,function() frame:Hide() end)
 frame.exp=btn(frame,'',18,-55,292,30,function() expIndex=expIndex%#expansions+1; refresh() end)
 frame.kind=btn(frame,'',324,-55,306,30,function() kindIndex=kindIndex%#kinds+1; refresh() end)
 frame.search=CreateFrame('EditBox',nil,frame,'InputBoxTemplate'); frame.search:SetSize(570,26); frame.search:SetPoint('TOPLEFT',36,-98); frame.search:SetAutoFocus(false); frame.search:SetScript('OnTextChanged',refresh); frame.search:SetScript('OnEscapePressed',function(self) self:ClearFocus() end)
 local searchLabel=frame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall'); searchLabel:SetPoint('TOPLEFT',20,-132); searchLabel:SetText('Search material, zone, or creature (type Felcloth)')
 frame.count=frame:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); frame.count:SetPoint('TOPLEFT',20,-154)
 for i=1,8 do
  local b=btn(frame,'',18,-173-(i-1)*28,285,26,function(self)
   selected=self.spot
   if selected then frame.detail:SetText(selected.zone..' ('..selected.x..', '..selected.y..')\nTarget: '..selected.mob..'\n\n'..selected.note) end
  end)
  results[i]=b
 end
 local detailBox=CreateFrame('Frame',nil,frame,'BackdropTemplate'); detailBox:SetSize(309,218); detailBox:SetPoint('TOPLEFT',320,-173); detailBox:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'}); detailBox:SetBackdropColor(.06,.10,.15,.9)
 frame.detail=detailBox:CreateFontString(nil,'OVERLAY','GameFontHighlight'); frame.detail:SetPoint('TOPLEFT',12,-12); frame.detail:SetWidth(283); frame.detail:SetJustifyH('LEFT'); frame.detail:SetJustifyV('TOP')
 btn(frame,'Show Map + Waypoint',330,-402,285,29,function() navigate(selected) end)
 frame:Hide(); refresh()
end
SLASH_MAPHUBFARM1='/mhfarm'
SlashCmdList.MAPHUBFARM=function()
 if not frame then create() end
 if frame:IsShown() then frame:Hide() else frame:Show() end
end
MapHubOpenFarming=function() if not frame then create() end frame:Show() end