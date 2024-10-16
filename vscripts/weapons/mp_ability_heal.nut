global function OnWeaponChargeBegin_ability_heal
global function OnWeaponPrimaryAttack_ability_heal
global function OnWeaponChargeEnd_ability_heal
global function OnWeaponAttemptOffhandSwitch_ability_heal

bool function OnWeaponChargeBegin_ability_heal( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	float duration     = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
	StimPlayerWithOffhandWeapon( player, duration, weapon )

	weapon.EmitWeaponSound_1p3p( "octane_stimpack_loop_1P", "octane_stimpack_loop_3P" )
	PlayerUsedOffhand( player, weapon )

	thread StimEnd(weapon, duration)

	#if SERVER
	player.p.lastDamageTime = Time()
	int stimDamage = int(weapon.GetWeaponSettingFloat( eWeaponVar.damage_near_distance ))
	player.SetHealth( player.GetHealth() - stimDamage < 1 ? 1 : player.GetHealth() - stimDamage )

	if( Time() - player.p.lastStimChatterTime >= 30 )
	{
		player.p.lastStimChatterTime = Time()
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_tactical" )
	}

	#endif
	return true
}

void function StimEnd( entity weapon, float duration)
{
	if ( !IsValid( weapon ) )
		return

	EndSignal( weapon, "OnDestroy" )

	wait duration-2

	weapon.EmitWeaponSound_1p3p( "octane_stimpack_deactivate_1P", "octane_stimpack_deactivate_3P" )
}

void function OnWeaponChargeEnd_ability_heal( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()

	#if CLIENT
	if( !IsValid( player ) || player != GetLocalClientPlayer() )
		return
	#endif

	weapon.SetWeaponPrimaryClipCount( 0 )
}


var function OnWeaponPrimaryAttack_ability_heal( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


bool function OnWeaponAttemptOffhandSwitch_ability_heal( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	return true
}