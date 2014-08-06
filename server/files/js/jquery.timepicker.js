/* jQuery timepicker
 * replaces a single text input with a set of pulldowns to select hour, minute, and am/pm
 *
 * Copyright (c) 2007 Jason Huck/Core Five Creative (http://www.corefive.com/)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) 
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Version 1.0
 */

(function($){
	jQuery.fn.timepicker = function(){
		this.each(function(){
			var mn;
			// get the ID and value of the current element
			var i = this.id;
			var v = $(this).val();
			
			// the options we need to generate
			var hrs = new Array('01','02','03','04','05','06','07','08','09','10','11','12');
			var mins = new Array('00','15','30','45');
			var ap = new Array('am','pm');
			
			// build the new DOM objects
			var output = '';
			
			output += '<select id="h_' + i + '" class="h timepicker">';
			for(hr=0; hr<hrs.length; hr++){
				output += '<option value="' + hrs[hr] + '"';
				if (hrs[hr] == '12') output += ' selected';
				output += '>' + hrs[hr] + '</option>';
			}
			output += '</select>';
			
			output += '<select id="m_' + i + '" class="m timepicker">';
			for(mn=0; mn<mins.length; mn++){
				output += '<option value="' + mins[mn] + '"';
				output += '>' + mins[mn] + '</option>';
			}
			output += '</select>';
			
			output += '<select id="p_' + i + '" class="p timepicker">';
			for(pp=0; pp<ap.length; pp++){
				output += '<option value="' + ap[pp] + '"';
				output += '>' + ap[pp] + '</option>';
			}
			output += '</select>';
			
			// hide original input and append new replacement inputs
			$(this).attr('type','hidden').after(output);
		});
		
		$('select.timepicker').change(function(){
			var i = this.id.substr(2);
			var h = $('#h_' + i).val();
			var m = $('#m_' + i).val();
			var p = $('#p_' + i).val();
			var v = h + ':' + m + ' ' + p;
			$('#' + i).val(v);
			updateTime();
		});
		
		return this;
	};
})(jQuery);



/* SVN: $Id: jquery.timepicker.js 456 2007-07-16 19:09:57Z Jason Huck $ */
