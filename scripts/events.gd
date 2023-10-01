extends Node


var puzzles = [
	{ 
		"puzzle": "aaasdfasdfasdf ffffffffffffffffffffffff aaaaaaaaaaaaaaaaaaaaaaaaaa",
		"quota": [40, 50, 60]
	},
	{ 
		"puzzle": 
"""     ACCOUNTING DATA     
=========================
ACCOUNT           BALANCE
=========================
000001        $100.00 USD
000002       $1040.02 USD
000003          $6.18 USD""", 
		"quota": [40, 45, 50],
	}
]
signal open_window(node)
signal close_window
signal reset_level
