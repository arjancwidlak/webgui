package WebGUI::Help::Asset_Subscription;

use strict; 


our $HELP = { 

	'template' => {	
		title => 'subscription template', 
		body => '',	
		isa => [
			{
			tag => 'sku properties',
			namespace => 'Asset_Sku',
			},
		],
		fields => [	
		],
		variables => [
			{	name => 'formHeader' , required=>1},
			{	name => 'formFooter' , required=>1 },
			{	name => 'purchaseButton' , required=>1 },
			{	name => 'hasAddedToCart' , required=>1 },
			{	name => 'continueShoppingUrl' },
			{	name => 'codeControls' , required=>1 },
			{	name => 'thankYouMessage', description=>'thank you message help' },
			{	name => 'redeemCodeLabel' , required=>1 },
			{	name => 'redeemCodeUrl' , required=>1 },
			{	name => 'price' , required=>1 },
		],
		related => [  
		],
	},

	'redeem subscription template' => {	
		title => 'help redeem code template title', 
		body => '',	
		isa => [ ],
		fields => [	],
		variables => [
			{ name => 'batchDescription' , required=>1},
			{ name => 'message' , required=>1 },
			{ name => 'codeForm' , required=>1 },
		],
		related => [  
		],
	},

};

1; 
