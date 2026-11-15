params ["_s","_payout","_text"];_s set ["phase","finished"];_s set ["payout",floor (_payout max 0)];_s set ["message",_text];true
