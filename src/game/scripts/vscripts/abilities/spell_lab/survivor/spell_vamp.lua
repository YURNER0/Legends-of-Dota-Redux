if spell_lab_survivor_spell_vamp == nil then
	spell_lab_survivor_spell_vamp = class({})
end

LinkLuaModifier("spell_lab_survivor_spell_vamp_modifier", "abilities/spell_lab/survivor/spell_vamp.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_spell_vamp:GetIntrinsicModifierName() return "spell_lab_survivor_spell_vamp_modifier" end


if spell_lab_survivor_spell_vamp_modifier == nil then
	spell_lab_survivor_spell_vamp_modifier = class({})
end

function spell_lab_survivor_spell_vamp_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_spell_vamp_modifier:OnTakeDamage(keys)
	if IsServer() then
		if keys.damage_type ~= DAMAGE_TYPE_MAGICAL then return end
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
			local heal = self:GetStackCount()*0.01*keys.damage
			keys.attacker:Heal(heal, hAbility)
    	ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		end
	end
end

function spell_lab_survivor_spell_vamp_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_spell_vamp_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_spell_vamp_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_spell_vamp_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_spell_vamp_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		if not self:GetParent():IsRealHero() then
  local hOwner = self:GetParent():GetOwner()
  if hOwner ~= nil then
    local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName("spell_lab_survivor_spell_vamp_modifier")
    if hOriginModifier ~= nil then
      self:SetStackCount(hOriginModifier:GetStackCount())
    end
  end
end
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_spell_vamp_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsRealHero() then
			self:StartIntervalThink( -1 )
			return
		end
    if not self:GetParent():IsAlive() and not self:GetParent():IsReincarnating() then
  		self.lastdeath = GameRules:GetGameTime()
  		self:SetStackCount(0)
      return
    end
  	if self:GetAbility():GetLevel() > 0 then
      local stacks = (GameRules:GetGameTime() - self.lastdeath)*self:GetAbility():GetSpecialValueFor("bonus")*0.0166667
  		self:SetStackCount(stacks)
  	end
	end
end

function spell_lab_survivor_spell_vamp_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
