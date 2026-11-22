local _, Addon = ...
local function api() return Addon.EnemyCooldowns end
local panel = CreateFrame('Frame','NexosCD_TrackerSettings',UIParent,'BackdropTemplate')
panel:SetSize(525,720); panel:SetPoint('CENTER'); panel:SetFrameStrata('DIALOG')
panel:SetMovable(true); panel:EnableMouse(true); panel:RegisterForDrag('LeftButton')
panel:SetScript('OnDragStart',panel.StartMoving)
panel:SetScript('OnDragStop',panel.StopMovingOrSizing)
panel:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
panel:Hide()
local title=panel:CreateFontString(nil,'OVERLAY','GameFontNormalLarge')
title:SetPoint('TOP',0,-18); title:SetText('NexosCD Tracker - Target Enemy Cooldown Tracker')
local close=CreateFrame('Button',nil,panel,'UIPanelCloseButton'); close:SetPoint('TOPRIGHT',-5,-5)
local y=-55
local checks={}
local function heading(label)
 local t=panel:CreateFontString(nil,'OVERLAY','GameFontNormal'); t:SetPoint('TOPLEFT',23,y); t:SetText(label); y=y-28
end
local function toggle(label,get,set)
 local b=CreateFrame('CheckButton',nil,panel,'UICheckButtonTemplate')
 b:SetPoint('TOPLEFT',20,y); b.text:SetText(label)
 b:SetScript('OnClick',function(self) local a=api(); if a then set(a,self:GetChecked()) end end)
 checks[#checks+1]={button=b,get=get}
 y=y-31
end
local function slider(label,get,set,min,max)
 local text=panel:CreateFontString(nil,'OVERLAY','GameFontNormal')
 text:SetPoint('TOPLEFT',27,y); text:SetText(label)
 local s=CreateFrame('Slider',nil,panel,'OptionsSliderTemplate')
 s:SetPoint('TOPLEFT',35,y-22); s:SetWidth(400)
 s:SetMinMaxValues(min,max); s:SetValueStep(1)
 if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
 s.Low:SetText(tostring(min)); s.High:SetText(tostring(max)); s.Text:SetText('')
 s:SetScript('OnValueChanged',function(self,v)
  if not self.loading then local a=api(); if a then set(a,math.floor(v+0.5)) end end
 end)
 checks[#checks+1]={slider=s,get=get}
 y=y-70
end
heading('TRACKER DISPLAY')
toggle('Show tracked cooldowns above Target Frame',function(a) return a:GetTargetEnabled() end,function(a,v) a:SetTargetEnabled(v) end)
toggle('Show tracked cooldowns above Nameplates',function(a) return a:GetNameplateEnabled() end,function(a,v) a:SetNameplateEnabled(v) end)
toggle('Mouseover Tracker (temporarily show hovered player)',function(a) return a:GetTargetMouseover() end,function(a,v) a:SetTargetMouseover(v) end)
toggle('Track enemy players',function(a) return a:GetEnemy() end,function(a,v) a:SetEnemy(v) end)
toggle('Track friendly players',function(a) return a:GetFriendly() end,function(a,v) a:SetFriendly(v) end)
toggle('Sound alerts',function(a) return a:GetSounds() end,function(a,v) a:SetSounds(v) end)
heading('COOLDOWN CATEGORIES')
for _,entry in ipairs({{'INT','Interrupts'},{'DEF','Defensives'},{'OFF','Offensives'},{'CC','Crowd Control'},{'MOB','Mobility'}}) do
 local category,label=entry[1],entry[2]
 toggle(label,function(a) return a:GetCategory(category) end,function(a,v) a:SetCategory(category,v) end)
end
heading('TARGET LAYOUT')
slider('Icon Size',function(a) return a:GetTargetIconSize() end,function(a,v) a:SetTargetIconSize(v) end,16,64)
slider('Icon Spacing',function(a) return a:GetTargetSpacing() end,function(a,v) a:SetTargetSpacing(v) end,0,20)
slider('Icons Per Row',function(a) return a:GetTargetPerRow() end,function(a,v) a:SetTargetPerRow(v) end,1,20)
local reset=CreateFrame('Button',nil,panel,'UIPanelButtonTemplate')
reset:SetSize(130,24); reset:SetPoint('BOTTOMRIGHT',-22,18); reset:SetText('Reset Layout')
reset:SetScript('OnClick',function() local a=api(); if a then a:ResetTargetLayout(); panel:Hide(); panel:Show() end end)
panel:SetScript('OnShow',function()
 local a=api(); if not a then return end
 for _,item in ipairs(checks) do
  if item.button then item.button:SetChecked(item.get(a)) else
   item.slider.loading=true; item.slider:SetValue(item.get(a)); item.slider.loading=false
  end
 end
end)
local function togglePanel() if panel:IsShown() then panel:Hide() else panel:Show() end end
SLASH_NEXOSCD1='/nexoscd'; SlashCmdList.NEXOSCD=function() togglePanel() end
-- Circular draggable minimap button. Saved separately from cooldown tracker settings.
local minimap=CreateFrame('Button','NexosCD_MinimapButton',Minimap)
minimap:SetSize(30,30)
minimap:SetFrameStrata('MEDIUM')
minimap:SetFrameLevel(Minimap:GetFrameLevel()+8)
minimap:SetMovable(true)
minimap:EnableMouse(true)
local tex=minimap:CreateTexture(nil,'ARTWORK')
tex:SetAllPoints(minimap)
tex:SetTexture('Interface\\AddOns\\NexosCD\\media\\nexoscd_minimap.tga')
local function positionButton(angle)
 local radius=(Minimap:GetWidth() or 140)/2+10
 local radians=math.rad(angle)
 minimap:ClearAllPoints()
 minimap:SetPoint('CENTER',Minimap,'CENTER',math.cos(radians)*radius,math.sin(radians)*radius)
end
local function getAngle()
 local cx,cy=Minimap:GetCenter()
 if not cx or not cy then return 225 end
 local scale=UIParent:GetEffectiveScale()
 local mx,my=GetCursorPosition()
 mx,my=mx/scale,my/scale
 return math.deg(math.atan2(my-cy,mx-cx))
end
local function stopDragging(self)
 self:SetScript('OnUpdate',nil)
 self.dragging=false
 local angle=getAngle()
 NexosCDMinimapDB=NexosCDMinimapDB or {}
 NexosCDMinimapDB.angle=angle
 positionButton(angle)
end
minimap:RegisterForDrag('LeftButton')
minimap:SetScript('OnDragStart',function(self)
 self.dragging=true
 self:SetScript('OnUpdate',function() positionButton(getAngle()) end)
end)
minimap:SetScript('OnDragStop',stopDragging)
minimap:RegisterForClicks('LeftButtonUp','RightButtonUp')
minimap:SetScript('OnClick',function(self,button)
 if self.dragging then return end
 togglePanel()
end)
minimap:SetScript('OnEnter',function(self)
 GameTooltip:SetOwner(self,'ANCHOR_LEFT')
 GameTooltip:AddLine('NexosCD Tracker')
 GameTooltip:AddLine('Click: Cooldown Tracker settings',1,1,1)
 GameTooltip:AddLine('Left-drag: Move around minimap',0.7,0.85,1)
 GameTooltip:Show()
end)
minimap:SetScript('OnLeave',function() GameTooltip:Hide() end)
local init=CreateFrame('Frame')
init:RegisterEvent('PLAYER_LOGIN')
init:SetScript('OnEvent',function()
 NexosCDMinimapDB=NexosCDMinimapDB or {}
 positionButton(tonumber(NexosCDMinimapDB.angle) or 225)
end)
