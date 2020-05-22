////////////////////////////////////////////////////////////////////////////////
//	This file contains the following modules :
//
//		* Predictions
//		* Utils
//		* BracketsImportTournament
//		* BracketsTournamentsLayoutButtons
//		* BracketsMatchesPrediction
//		* BracketsTreeViewHTML
/////////////////////////////////////////////////////////////////////////////// 

//Remove all jQuery variables from the global scope
var brackets = jQuery.noConflict();

//functions



//------------------------------------------------------------------------------
//   Predictions module	
//------------------------------------------------------------------------------

var Predictions = Predictions || function(brackets){
	//--------------------------------------------------------------------------
	// Private attributes
	//--------------------------------------------------------------------------
	
	var ROUND_WIDTH    = 155;
	var matchData      = {};
	var cupImg         = '';
	var nflImg         = '';
	var userTournament = '';
	var group          = '';
	var predictionsCol = [];
	var isNfl          = false;
	
	//--------------------------------------------------------------------------
	// Setters / Getters
	//--------------------------------------------------------------------------

	function setImages( c, n )       { cupImg = c; nflImg = n; 	}
	function setUserTournament( ut ) { userTournament = ut;    	}
	function setGroup( g )           { group = g;              	}
	function setIsNfl( nfl )         { isNfl = nfl;            	}
	function setMatchData( k, v)	 { matchData[k] = v	  		}

	//--------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------

	/**
	 * Init predictions module
	 *
	 * @param md Match data associative array
	 */
	function init(){
		setSizes();
		initTeamsAndMatches();
		if( group ){
			// Tournament disabled?
			brackets('div.tournament.tournament-disabled').click( function(){
				parent.jQuery('.tournamentBlock').fadeIn( function(){
					 setTimeout('parent.jQuery(".tournamentBlock").fadeOut()',5000);	
				} );
			});
			
			initRounds();
			initDragAndDrop();
		}
	};

	/**
	 * Init rounds
	 */
	 function initRounds(){
		brackets('div.tournament .round-disabled').click( function(){
			var teamObj = brackets(this).children( '.team:not(.superchampion, champion)' );
			parent.jQuery('.roundBlock').fadeIn( function(){
				 if( teamObj.size() ){ showMatchDetail(teamObj); }
				 setTimeout('parent.jQuery(".roundBlock").fadeOut()',5000);	
			} );
			
		});
	 }
	 
	/**
	 * Init team related 
	 */
	function initTeamsAndMatches(){
		brackets('.tournament .team').hover(
			function(){ brackets(this).addClass('highlight'); },
			function(){ brackets(this).removeClass('highlight') }
		);

		brackets('.tournament div.diamond').hover( 
			function(){ showMatchDetail( brackets(this) ) },
			function(){ brackets(this).tipsy("hide"); }
		);

		brackets('.team').hover( 
			function(){ tipsyTeam( brackets(this) );  },
			function(){ brackets(this).tipsy("hide"); }
		);
	
	}
	
	function showMatchDetail( obj ){
		obj.tipsy({
			trigger: 'manual',
			html : true,
			gravity: 'nw',
			opacity: 1.0,
			title: function() { return brackets('#detail'+ obj.parent().parent().attr('Id')).html() }
			});
		obj.tipsy("show");
	}
	
	/**
	 * Show team popup 
	 */
	function tipsyTeam( elem ){
		elem.tipsy({
			gravity : 'nw',
			opacity : 1.0,
			trigger : 'manual',
			html    : true,
			title   : function(){
				return brackets('div[name=teamDescription]', elem).html();
			}
		}); 
		elem.tipsy("show");
	}

	/**
	 * Init draggable & droppable elements
	 */	
	function initDragAndDrop(){
		if( !brackets( ".tournament.tournament-disabled" ).size() ){
			brackets( ".tournament .draggable" ).filter( function(){
				return !brackets(this).parents().hasClass('round-disabled') &&
				       !(brackets(this).hasClass('team-empty')     ||
				         brackets(this).hasClass('champion-empty') ||
				         brackets(this).hasClass('superchampion-empty'));
			}).dblclick(function(){
				 makeDrop(brackets(this));
				 save();
			});
			emtpyTeamsCount();
		}
	}


	/**
	 * Make team drop
	 */
	 function makeDrop( teamSource ) {
	 	var objMatch	= matchData[ teamSource.parent().parent().attr('id') ];
	 	var matchDest	= objMatch.next;
		var CleanPath	= true;
		
		if( matchDest != '' ){
			var teamDest	= brackets( 'div#' + matchDest +' div.team' ).filter(function(){ 
								return objMatch.nextIsHome && brackets( this ).hasClass('home')
								|| !objMatch.nextIsHome && brackets( this ).hasClass('visitor');								
							}); 
		}else{
			var teamDest	= brackets( 'div#' + matchDest +' div.champion' ).add(' div.superchampion'); 
			CleanPath		= false;
		}
		
							
							
		var match        = matchDest;
		var currentTeam  = teamDest.attr('name');
		var currentMatch = match;
		var matchPath    = [];
	
	
		if( teamSource.attr('name') != currentTeam ){
			// Create team node
			brackets( teamDest ).replaceWith(function(){
				if( brackets(this).hasClass('champion') ){
					return '<div name="' + teamSource.attr('name') + '" class="team champion droppable prediction" predid="' + 
						teamSource.attr('predid') + '"><div name="teamDescription" style="display: none;">' + 
						teamSource.find('div[name=teamDescription]').html() + '</div><span>' + teamSource.find('.name').text() + '</span></div>';
				}
				else if( brackets(this).hasClass('superchampion') ){
					return '<div name="' + teamSource.attr('name') + '" class="team superchampion droppable prediction" predid="' + 
						teamSource.attr('predid') + '"><div name="teamDescription" style="display: none;">' + 
						teamSource.find('div[name=teamDescription]').html() + '</div><span class="name" style="width: 100%;">' + 
						teamSource.find('.name').text() + '</span></div>';
				}
				else if( brackets(this).hasClass('champion-left') ){
					return '<div name="' + teamSource.attr('name') + '" class="team champion-left draggable droppable prediction ' + 
						( brackets(this).hasClass('home') ? 'home' : 'visitor') + '"><div name="teamDescription" style="display: none;">' + 
						teamSource.find('div[name=teamDescription]').html() + '</div><span class="name" style="width: 100%;">' + 
						teamSource.find('.name').text() + '</span></div>';
				}
				else if( brackets(this).hasClass('champion-right') ){
					return '<div name="' + teamSource.attr('name') + '" class="team champion-right draggable droppable prediction ' + 
						( brackets(this).hasClass('home') ? 'home' : 'visitor') + '"><div name="teamDescription" style="display: none;">' + 
						teamSource.find('div[name=teamDescription]').html() + '</div><span class="name" style="width: 100%;">' + 
						teamSource.find('.name').text() + '</span></div>';
				}
				else{
					return '<div name="' + teamSource.attr('name') + '" class="team inner unlocked draggable droppable prediction ' + 
						( brackets(this).hasClass('home') ? 'home' : 'visitor') + '"><div name="teamDescription" style="display: none;">' + 
						teamSource.find('div[name=teamDescription]').html() + '</div><span class="name">' + 
						teamSource.find('.name').text() + '</span></div>';
				}
			});

			// Clean path
			if( currentTeam && CleanPath ){
				var nodeSet;
				
				if( matchData[currentMatch].next == ''){
					nodeSet = brackets('.tournament div.champion').add('.tournament div.superchampion');
				}
				else{
					do {
						matchPath.push( '.tournament div#' + currentMatch );
						currentMatch = matchData[currentMatch].next;
					} while( matchData[currentMatch] );

					nodeSet = brackets( matchPath.join(',') ).find('div.champion, div[name=' + currentTeam + ']');
				}
				
				nodeSet.replaceWith(function(){
					if( brackets(this).hasClass('champion') ){
						return '<div name="" class="team champion champion-empty droppable" predid="' + teamSource.attr('predid') + '"><div name="teamDescription" style="display: none;"></div><span class="name">?</span></div>';
					}
					else if( brackets(this).hasClass('superchampion') ){
						return '<div name="" class="team superchampion superchampion-empty droppable" predid="' + teamSource.attr('predid') + '"><div name="teamDescription" style="display: none;"></div><span class="name" style="width: 100%;">?</span></div>';
					}
					else if( brackets(this).hasClass('champion-left') ){
						return '<div name="" class="team home champion-left champion-empty droppable"><div name="teamDescription" style="display: none;"></div><span class="name" style="width: 100%;">?</span></div>';
					}
					else if( brackets(this).hasClass('champion-right') ){
						return '<div name="" class="team visitor champion-right champion-empty droppable"><div name="teamDescription" style="display: none;"></div><span class="name" style="width: 100%;">?</span></div>';
					}
					else{
						return '<div name="" class="team team-empty inner droppable ' + ( brackets(this).hasClass('home') ? 'home' : 'visitor' ) + '"><div name="teamDescription" style="display: none;"></div>?</div>';
					}
				});
			}
	
			// Update
			setSizes();
			initDragAndDrop();
			
			brackets('.team').hover( 
				function(){ tipsyTeam( brackets(this) );  },
				function(){ brackets(this).tipsy("hide"); }
			);
		}	
	}
	
	/**
	 * Returns true if can accept the team drag and drop
	 */
	 function acceptDrag(draggable){
		var matchid = draggable.parent().attr('id');

		if( matchData[matchid] ) {
			var isHome      = brackets(this).hasClass('home');
			var isPrevMatch = (this.parentNode && matchData[matchid].next == this.parentNode.id ) && 
							  ((matchData[matchid].nextIsHome  && isHome ) || (!matchData[matchid].nextIsHome && !isHome)) &&
							  !( brackets(this).hasClass('superchampion') || brackets(this).hasClass('champion'));
			var isLastMatch;
			
			if( isNfl ){
				 isLastMatch = matchid && !matchData[matchid].next && brackets(this).hasClass('superchampion');
			}
			else{
				isLastMatch = matchid && !matchData[matchid].next && brackets(this).hasClass('champion');
			}
			
			if( isPrevMatch || isLastMatch ){
				return true;    	
			}
		}
		
		return false;
	 }

	/**
	 * Set the tree elements height
	 */
	function setSizes(){
		if( isNfl ){
			brackets('div.tournament').css('width', (ROUND_WIDTH * 7) + 'px');
			setNflHeights();
		}
		else{ 
			var round_size = brackets('.tournament .round').size();
			brackets('div.tournament').css('width', (ROUND_WIDTH * round_size) + 'px');
			setStandardHeights();
		}
		brackets('div.tournament').css('margin-left', 'auto');
		brackets('div.tournament').css('margin-right', 'auto');
	}

	/**
	 * Set the tree elements height
	 */
	function setStandardHeights(){
		var h_block = 0;
		var h_ini   = 0;
		
		// Rounds
		brackets('.tournament .round').each(function(i, round){
			h_block = 40 * Math.pow(2, i);
			
			// Spacers
			brackets('.spacer', round).each(function(j, spacer){
				brackets(spacer).height( !i ? h_block : (!j ? h_ini : h_block));
			});

			h_ini += h_block / 2;
			
			// Matches
			brackets('.match', round).each(function(k, match){
				brackets(match).height(h_block - 2);
				
				// Teams
				brackets('.team', match).each(function(l, team){
					if( brackets(team).hasClass('champion') ){
						brackets(team).css('top', (h_block/2 - 50) + 'px');
					}
					else if(l){
						brackets(team).css('bottom', (-10 + 3 -(h_block - 40)) + 'px');
					}
				});
			});
		});
	}
	
	/**
	 * Set the tree elements height
	 */
	function setNflHeights(){
		var h_block   = [];
		var h_ini     = [];
		var index_map = [0, 1, 2, -1, 2, 1, 0];
		
		h_ini.push(0);
		
		// Rounds
		brackets('.tournament .round').each(function(i, round){
			if( i < 3){
				h_block.push( 40 * Math.pow(2, i) );
				h_ini.push( h_ini[h_ini.length - 1] + h_block[i] / 2 );
			}	
			
			if( i != 3 ){
				// Spacers
				brackets('.spacer', round).each(function(j, spacer){
					brackets(spacer).height( !index_map[i] ? h_block[index_map[i]] : (!j ? h_ini[index_map[i]] : h_block[index_map[i]]) );
				});
				
				// Matches
				brackets('.match', round).each(function(k, match){
					brackets(match).height(h_block[index_map[i]] - 2);
					
					// Teams
					brackets('.team', match).each(function(l, team){
						brackets(team).css('bottom', (-10 + 3 -(h_block[index_map[i]] - 40)) + 'px');
					});
				});
			}
		});
	}


	/**
	 * Save the predictions
	 */
	function save(){
		addPredictions();
		
		brackets('#ShowMsg').removeAttr('class').text('').fadeOut(); 

		brackets('div#jSonField input').val( predToJSON() );
		//doSave();
	}
	
	/**
	 * Add new or updated predictions to collection
	 */
	function addPredictions(){
		predictionsCol = [];

		// Add new and updated predictions
		brackets('.tournament div.prediction').each(function(){
				var isHome     = brackets(this).hasClass('home');
				var isChampion = isNfl ?  brackets(this).hasClass('superchampion') : brackets(this).hasClass('champion');
				var teamid     = brackets(this).attr('name');
				var predid     = isChampion 
					? brackets(this).attr('predid')
					: isHome ? brackets(this).parent().parent().attr('hpredid') : brackets(this).parent().parent().attr('vpredid');
				var fmatchid   = brackets(this).parent().parent().attr('id');
				var matchid    = isChampion ? fmatchid : getPredictionMatch( fmatchid, isHome ); 
	
				predictionsCol.push({
					'matchId'   : matchid,
					'teamId'    : teamid,
					'userPred'  : predid,
					'userTour'  : userTournament
				});
		});

		// Add empty predictions
		brackets('.tournament .team-empty').add('.tournament .champion-empty').add('.tournament .superchampion-empty').each(function(){
			var isHome     = brackets(this).hasClass('home');
			var isChampion = isNfl ?  brackets(this).hasClass('superchampion') : brackets(this).hasClass('champion');
			var predid     = isChampion 
				? brackets(this).attr('predid')
				: isHome ? brackets(this).parent().parent().attr('hpredid') : brackets(this).parent().parent().attr('vpredid');
			
			if( predid && predid != '' ){
				var fmatchid = brackets(this).parent().parent().attr('id');
				var matchid  = isChampion ? fmatchid : getPredictionMatch( fmatchid, isHome ); 
	
				predictionsCol.push({
					'matchId'   : matchid,
					'teamId'    : '',
					'userPred'  : predid,
					'userTour'  : userTournament
				});
			}
		});
	}
	

	/**
	 * Returns the parent match id
	 * 
	 * @param fmatchid Id of the current match
	 * @param isHome   True if the current team is home
	 */
	function getPredictionMatch( matchid, isHome ){
		var pid = matchid;
		
		for( var mid in matchData ){
			if( (matchData[mid].next == matchid) && 
			    ((matchData[mid].nextIsHome && isHome) || (!matchData[mid].nextIsHome && !isHome)) 
			){
				pid = mid;
				break;
			}
		}
		
		return pid;
	}

	/**
	 * Parse the prediction collection to a JSON string
	 */
	function predToJSON(){
		var jsonSTR = '{ ';

		for(var i=0 ; i < predictionsCol.length ; i++){
			jsonSTR += '"'+ i +'" : { ';
			
			jsonSTR += ' "matchId" : ';
			jsonSTR += '"'+ predictionsCol[i].matchId  + '" , ';
			
			jsonSTR += ' "teamId" : ';
			jsonSTR += '"'+  predictionsCol[i].teamId + '" , ';

			jsonSTR += ' "userPred" : ';
			jsonSTR += '  "'+ predictionsCol[i].userPred + '" , ';
			
			jsonSTR += ' "userTour" : ';
			jsonSTR += '  "'+ predictionsCol[i].userTour + '" },';
		}

		jsonSTR = jsonSTR.substr(0,jsonSTR.length-1) + '}';
		return jsonSTR;
	}
	
	/**
	 * Count empty teams
	 */
	 function emtpyTeamsCount(){
	 	brackets('.missing-predictions-number').html(
	 		brackets('.team-empty').add('.champion-empty').add('.superchampion-empty').size()
	 	);
	 }
	
	//--------------------------------------------------------------------------
	// Public methods
	//--------------------------------------------------------------------------

	return {
		setImages           : setImages,
		setUserTournament   : setUserTournament,
		setGroup            : setGroup,
		setIsNfl            : setIsNfl,
		setMatchData	    : setMatchData,
		acceptDrag          : acceptDrag,
		makeDrop            : makeDrop,
		init                : init,
		initDragAndDrop     : initDragAndDrop,
		setSizes            : setSizes,
		save                : save,
		tipsyTeam           : tipsyTeam
	}
}(jQuery);

//------------------------------------------------------------------------------
// Utils Module
//------------------------------------------------------------------------------
var BracketsUtils = BracketsUtils || function(brackets){
	
	//--------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------
	
    /**
    * Returns a part of Domain of Salesforce with dots like : ' .na7.force.com '
    * @return domainUrl
    */
    function domainUrl(domain){
        return 'http://'+domain + getNAHost() + 'force.com/';
    }
    
    /**
    * Get the 'na?' subdomain from salesforce;
    * @return naHost
    */
    function getNAHost(){
        var url = location.href;
        var reg = new RegExp('\\.([a-zA-Z]{2}[0-9])\\.');
        var naHost = reg.exec( url );
        return ( naHost.length > 0 ) ? naHost[0] : '';
    }
    
    function isValidUrl(url) {
		return url.match(/^\s*(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?\s*brackets/);
	}
    //--------------------------------------------------------------------------
	// Public methods
	//--------------------------------------------------------------------------
    return {
    	domainUrl : domainUrl,
    	getNAHost : getNAHost,
    	isValidUrl : isValidUrl
    }
}(jQuery);

//------------------------------------------------------------------------------
// BracketsTournamentsLayoutButtons Module
//------------------------------------------------------------------------------

var BracketsTournamentsLayoutButtons = BracketsTournamentsLayoutButtons || function (brackets){
	
	//workaround
	var that = this;
	//--------------------------------------------------------------------------
	// Private attributes
	//--------------------------------------------------------------------------
	var domain;
	
	//--------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------
	
	function init(domain){
		that.domain = domain;
		brackets(document).ready(function(){ 
    		setText();	
        });
	}

	function setText(){
		brackets('.scg span').text( BracketsUtils.domainUrl(that.domain) );
        brackets('#urlparm input').val( BracketsUtils.domainUrl(that.domain) ); 		
	}
	
    function publish(){
        showloader();
        if(doPublish){
        	doPublish();
        }
    }
    
    function showloader() {
        if( brackets('#loader').is(':visible') ){
        	brackets('#loader').fadeOut();
        }else{
        	brackets('#loader').fadeIn();
        }
    }
    
    function finishPublish(){
        setText();
    }
    
    //--------------------------------------------------------------------------
	// Public methods
	//--------------------------------------------------------------------------
    return {
    	init : init,
    	publish : publish,
    	showloader : showloader,
    	finishPublish : finishPublish
    }
}(jQuery);

//------------------------------------------------------------------------------
// BracketsImportTournament Module
//------------------------------------------------------------------------------

var BracketsImportTournament = BracketsImportTournament || function(brackets){
	
	//--------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------
	function init(){
		brackets(document).ready(function(){ 
    		brackets('input.url_btn.btn').click( function(){
   				var url =  brackets('input.url').val();
   				if( BracketsUtils.isValidUrl( url ) ){ 
   					doImport(); 
   					brackets('input.url').val('');
					brackets(this).hide();
   				}
   				else { 
   					alert('Invalid URL\nPlease verify if all the parameters and protocol( "http:,https:" ) are included') 
   				};
   			});
        });
	}
	
	function allowButton(){ 
		brackets('input.url_btn.btn').show();
	}
	//--------------------------------------------------------------------------
	// Public methods
	//--------------------------------------------------------------------------
	
	return {
		init 	: init,
		allow	: allowButton
	}
}(jQuery)

var BracketsMatchesPrediction = BracketsMatchesPrediction || function(brackets){
	
	var that = this; 
	//--------------------------------------------------------------------------
	// Private attributes
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------
	 
	
	function resizeFrame( minHeight ){
		var divHe = parent && parent.TreeFrame && parent.TreeFrame.document.getElementById('bodyHeight');
		if( minHeight ){
			var he = divHe 
				? divHe.offsetHeight > minHeight ? divHe.offsetHeight + 120 : minHeight
				: minHeight;

			brackets('#TreeFrame', parent.document).attr('height', he );
		}
		else if( divHe != null ) {
			var he = divHe.offsetHeight + 120;
			brackets('#TreeFrame', parent.document).attr('height', he );
		}	
	}
	//--------------------------------------------------------------------------
	// Public methods
	//--------------------------------------------------------------------------
	
	return {
		resizeFrame     : resizeFrame
	}
}(jQuery);
