-- Map Hub Explorer v0.3.9: integrated searchable guides, planner, collection and tracking.
-- Locations are intentionally limited to documented starter records; no fabricated database.
local records={
 {id='felcloth',name='Felcloth',type='Farming',exp='Classic',zone='Felwood',map=77,x=43,y=20,source='Jadefire satyrs',details='Classic-era satyr farming location. Drops and enemies differ by WoW edition. Verify in Retail.'},
 {id='mageweave',name='Mageweave Cloth',type='Farming',exp='Classic',zone='Tanaris',map=71,x=43,y=56,source='Dunemaul ogres',details='Classic-era humanoid cloth farming option. Not a guaranteed best yield.'},
 {id='diremaul',name='Dire Maul East entrance',type='Dungeon',exp='Classic',zone='Feralas',map=69,x=59,y=45,source='Dungeon entrance area',details='Approximate outdoor map destination; entrance may require walking from the waypoint.'},
 {id='tailor',name='Tailoring knowledge checklist',type='Profession',exp='All',details='Review first crafts, specialization points, trainer recipes, profession quests and expansion-specific one-time treasures.',steps={'Inspect the Tailoring specialization window','Check first-craft bonuses','Review available profession quests','Find uncollected knowledge treasures using verified sources'}},
 {id='leather',name='Leatherworking knowledge checklist',type='Profession',exp='All',details='Review first crafts, specialization points, trainer recipes, profession quests and one-time treasures.',steps={'Inspect the Leatherworking specialization window','Check first-craft bonuses','Review available profession quests','Find uncollected knowledge treasures using verified sources'}},
 {id='secret',name='Multi-NPC treasure puzzle guide',type='Secret',exp='All',details='General puzzle walkthrough template, not a specific verified treasure.',steps={'Read the clue and identify prerequisites','Find and speak with the first NPC','Follow the remaining clues in order','Return to the chest and claim the reward'}},
 {id='mount',name='Mount collection checklist',type='Mount',exp='All',details='Open Collections > Mounts to inspect missing mounts. Verified individual drop sources can be added to data packs.',steps={'Pick an uncollected mount','Confirm its source and prerequisites','Travel to the correct zone or instance','Mark it complete after collection'}},
 {id='pet',name='Battle pet collection checklist',type='Pet',exp='All',details='Open Collections > Pet Journal to inspect missing pets.',steps={'Choose a missing pet','Check its acquisition method','Visit the source location','Mark it collected'}},
 {id='transmog',name='Transmog appearance checklist',type='Transmog',exp='All',details='Use the in-game appearances collection to find missing looks. Availability can depend on class, difficulty and game version.',steps={'Open the Appearances collection','Choose a missing appearance','Verify its source and eligible difficulty','Collect the appearance'}},
 {id='quest',name='Quest chain troubleshooting',type='Quest',exp='All',details='General checklist for quests that appear unavailable. Specific quest prerequisites require verified guide records.',steps={'Inspect the quest log and map','Check required prior quests','Check campaign and reputation prerequisites','Return to the quest giver'}},
 {id='recipe',name='Recipe source checklist',type='Recipe',exp='All',details='Use the profession window to identify missing recipes. Source types include trainers, vendors, reputations, drops and quests.',steps={'Choose a missing recipe','Check trainer and vendor availability','Check reputation and quest requirements','Visit the verified source'}},
}
local expansions={'All','Classic','The Burning Crusade','Wrath of the Lich King','Cataclysm','Mists of Pandaria','Warlords of Draenor','Legion','Battle for Azeroth','Shadowlands','Dragonflight','The War Within','Midnight'}
local types={'All','Farming','Profession','Secret','Mount','Pet','Transmog','Dungeon','Quest','Recipe'}
local frame,shown,selected,expIndex,typeIndex,rows= nil,{},nil,1,1,{}
local function db()
 MapHubDB=MapHubDB or {}; MapHubDB.explorer=MapHubDB.explorer or {plans={},done={},prices={},counts={}}
 return MapHubDB.explorer
end
local function makeButton(p,text,x,y,w,h,fn)
 local b=CreateFrame('Button',nil,p,'UIPanelButtonTemplate'); b:SetSize(w,h); b:SetPoint('TOPLEFT',x,y); b:SetText(text); b:SetScript('OnClick',fn); return b
end
local function wp(r)
 if not (r and r.map and r.x and r.y) then print('Map Hub: This guide has no verified waypoint.'); return end
 if not (C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(r.map) and UiMapPoint) then print('Map Hub: Waypoint API unavailable for this map.'); return end
 local p=UiMapPoint.CreateFromCoordinates(r.map,r.x/100,r.y/100)
 C_Map.SetUserWaypoint(p)
 if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
 if WorldMapFrame and WorldMapFrame.SetMapID then WorldMapFrame:SetMapID(r.map); WorldMapFrame:Show() end
end
local function detail()
 if not frame then return end
 local d=db(); local r=selected
 if not r then frame.detail:SetText('No entries match. Try a different search or filter.\n\nThis release includes starter records and guide templates, not a full verified location database.'); return end
 local s=r.name..'\n'..r.type..'  •  '..r.exp..'\n'
 if r.zone then s=s..r.zone..' ('..r.x..', '..r.y..')\n' end
 if r.source then s=s..'Source: '..r.source..'\n' end
 s=s..'\n'..(r.details or '')
 if r.steps then for i,step in ipairs(r.steps) do s=s..'\n'..(d.done[r.id..':'..i] and '[x] ' or '[ ] ')..i..'. '..step end end
 frame.detail:SetText(s)
 frame.plan:SetText(d.plans[r.id] and 'Remove from Plan' or 'Add to Plan')
 frame.done:SetText(d.done[r.id] and 'Mark Unfinished' or 'Mark Complete')
end
local function refresh()
 if not frame then return end
 frame.exp:SetText('Expansion: '..expansions[expIndex]); frame.kind:SetText('Type: '..types[typeIndex])
 local query=string.lower(frame.search:GetText() or '')
 local matches={}
 for _,r in ipairs(records) do
  local hay=string.lower(r.name..' '..(r.zone or '')..' '..(r.source or '')..' '..r.type..' '..(r.details or ''))
  if (expIndex==1 or r.exp==expansions[expIndex] or r.exp=='All') and (typeIndex==1 or r.type==types[typeIndex]) and (query=='' or string.find(hay,query,1,true)) then matches[#matches+1]=r end
 end
 for i,b in ipairs(rows) do local r=matches[i]; b.entry=r; if r then b:SetText(r.name); b:Show() else b:Hide() end end
 frame.count:SetText(#matches..' entries (showing up to '..#rows..')')
 if not selected or not (function() for _,r in ipairs(matches) do if r==selected then return true end end end)() then selected=matches[1] end
 detail()
end
local function make()
 frame=CreateFrame('Frame','MapHubExplorer',UIParent,'BackdropTemplate'); frame:SetSize(770,555); frame:SetPoint('CENTER'); frame:SetFrameStrata('DIALOG'); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag('LeftButton'); frame:SetScript('OnDragStart',frame.StartMoving); frame:SetScript('OnDragStop',frame.StopMovingOrSizing)
 frame:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',edgeSize=28,insets={left=8,right=8,top=8}})
 local title=frame:CreateFontString(nil,'OVERLAY','GameFontNormalLarge'); title:SetPoint('TOPLEFT',20,-20); title:SetText('MAP HUB  |cff9db2c5v0.3.9|r  Explorer + Planner')
 makeButton(frame,'X',727,-14,25,25,function() frame:Hide() end)
 frame.exp=makeButton(frame,'',18,-55,350,27,function() expIndex=expIndex%#expansions+1; selected=nil; refresh() end)
 frame.kind=makeButton(frame,'',390,-55,360,27,function() typeIndex=typeIndex%#types+1; selected=nil; refresh() end)
 frame.search=CreateFrame('EditBox',nil,frame,'InputBoxTemplate'); frame.search:SetSize(690,25); frame.search:SetPoint('TOPLEFT',40,-98); frame.search:SetAutoFocus(false); frame.search:SetScript('OnTextChanged',function() selected=nil; refresh() end); frame.search:SetScript('OnEscapePressed',function(self) self:ClearFocus() end)
 frame.count=frame:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); frame.count:SetPoint('TOPLEFT',20,-137)
 for i=1,12 do rows[i]=makeButton(frame,'',18,-160-(i-1)*29,320,27,function(self) selected=self.entry; detail() end) end
 local right=CreateFrame('Frame',nil,frame,'BackdropTemplate'); right:SetSize(394,350); right:SetPoint('TOPLEFT',355,-160); right:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'}); right:SetBackdropColor(.04,.09,.15,.85)
 frame.detail=right:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall'); frame.detail:SetPoint('TOPLEFT',12,-13); frame.detail:SetWidth(368); frame.detail:SetJustifyH('LEFT'); frame.detail:SetJustifyV('TOP')
 frame.plan=makeButton(frame,'Add to Plan',355,-517,128,25,function() if selected then local p=db().plans; p[selected.id]=not p[selected.id] or nil; detail() end end)
 frame.done=makeButton(frame,'Mark Complete',490,-517,130,25,function() if selected then local d=db().done; d[selected.id]=not d[selected.id] or nil; detail() end end)
 makeButton(frame,'Waypoint',627,-517,123,25,function() wp(selected) end)
 frame:Hide(); refresh()
end
local function open() if not frame then make() end if frame:IsShown() then frame:Hide() else frame:Show() end end
SLASH_MAPHUBEXPLORE1='/mhexplore'; SlashCmdList.MAPHUBEXPLORE=open
SLASH_MAPHUBPLAN1='/mhplan'; SlashCmdList.MAPHUBPLAN=function()
 local d=db(); local n=0; print('|cffffd18aMap Hub Adventure Plan:|r')
 for _,r in ipairs(records) do if d.plans[r.id] then n=n+1; print((d.done[r.id] and '[DONE] ' or '[TODO] ')..r.name..(r.zone and (' - '..r.zone) or '')) end end
 if n==0 then print('No items planned. Use /mhexplore to add items.') end
end
SLASH_MAPHUBPROFIT1='/mhprofit'; SlashCmdList.MAPHUBPROFIT=function(msg)
 local material,count,price=msg:match('^(%S+)%s+(%d+)%s+(%d+)$')
 if not material then print('Map Hub: /mhprofit material quantity price-in-copper (e.g. /mhprofit Felcloth 20 50000)'); return end
 local total=tonumber(count)*tonumber(price); print('Map Hub: '..count..' '..material..' = '..GetCoinTextureString(total)..' at your entered unit price. No live auction data.')
end
MapHubOpenExplorer=open