function EssenceAmp(filterTable)
	local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    local ability_index = filterTable["entindex_inflictor_const"]
    if not victim_index or not attacker_index or not ability_index then
        return filterTable
    end
    local attacker = EntIndexToHScript( attacker_index )
    local victim = EntIndexToHScript( victim_index )
    local ability = EntIndexToHScript( ability_index )
	if attacker == victim then return filterTable end
	local amp = attacker:FindAbilityByName("ebf_mana_fiend_essence_amp")
	print(amp and amp:GetLevel() > 0, "ampcheck")
	if amp and amp:GetLevel() > 0 then
		local damageMult = amp:GetSpecialValueFor("crit_amp") / 100
		local manaburn = ability:GetManaCost(-1) * damageMult - ability:GetManaCost(-1)
		local perc = amp:GetSpecialValueFor("crit_chance")
		if attacker:GetMana() >= manaburn then
			attacker.essenceCritPrng = attacker.essenceCritPrng or 0
			if RollPercentage(perc-1+attacker.essenceCritPrng) then
				filterTable["damage"] = filterTable["damage"] * damageMult
				local particle = ParticleManager:CreateParticle("particles/essence_amp_crit.vpcf", PATTACH_POINT_FOLLOW, attacker)
				attacker:EmitSound("Hero_TemplarAssassin.Meld.Attack")
				victim:ShowPopup( {
							PostSymbol = 4,
							Color = Vector( 125, 125, 255 ),
							Duration = 0.7,
							Number = filterTable["damage"],
							pfx = "spell_custom"} )
				attacker:SpendMana(manaburn, ability)
				attacker.essenceCritPrng = 0
			else
				attacker.essenceCritPrng = attacker.essenceCritPrng + 1
			end
		end
	end
	return filterTable
 end