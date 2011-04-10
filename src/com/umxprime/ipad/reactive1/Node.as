/**
 Copyright © Maxime CHAPELET 2011
 umxprime@umxprime.com
 
 This software is a computer program whose purpose is to provide a dynamic graphical
 user interface aimed to manipulate digitized old art sketchbooks.
 
 This software is governed by the CeCILL license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL license and that you accept its terms.
 */

package com.umxprime.ipad.reactive1
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class Node extends Sprite
	{
		public var nodeID:int;
		public var speed:int;
		public var angle:int;
		public var prevX:int;
		public var prevY:int;
		public var curX:int;
		public var curY:int;
		public var disappear:Boolean;
		private var main:Main;
		
		public function Node(parent:Main)
		{
			main=parent;
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			this.draw();
		}
		
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function draw():void
		{
			this.graphics.beginFill(0xFF0000);
			this.graphics.drawCircle(0,0,50);
			this.graphics.endFill();
		}
	}
}