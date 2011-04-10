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
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	public class Main extends Sprite
	{
		private var touchEnabled:Boolean;
		private var nodesObject:Object;
		private var lastNode:Node;
		private var currentNodeId:uint = 0;
		private var animate:Timer = new Timer(10,1);
		private const OPTIMIZER:uint = 0xF;
		private const ANGLE0:uint = 0;
		private const ANGLE90:uint = (Math.PI/2)<<OPTIMIZER;
		private const ANGLE180:uint = (Math.PI)<<OPTIMIZER;
		private const ANGLE270:uint = (3*Math.PI/2)<<OPTIMIZER;
		private const COSTABLE:CosTable = new CosTable(OPTIMIZER);
		private const SINTABLE:SinTable = new SinTable(OPTIMIZER);
		private const RAD2DEG:Number = 180/Math.PI;
		private const DEG2RAD:Number = Math.PI/180;
		
		public function Main()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			isTouchEnabled();
		}
		private function isTouchEnabled():void
		{
			if(Multitouch.supportsTouchEvents)
			{
				touchEnabled=true;
				Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
			}
		}
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
			nodesObject = new Object();
			addListeners();
			animate.addEventListener(TimerEvent.TIMER_COMPLETE,disappear);
			animate.start();
		}
		
		private function addListeners():void
		{
			if(touchEnabled)
			{
				this.stage.addEventListener(TouchEvent.TOUCH_BEGIN,addNode);
				this.stage.addEventListener(TouchEvent.TOUCH_END,initDisappear);
			}else{
				this.stage.addEventListener(MouseEvent.MOUSE_DOWN,addNode);
				this.stage.addEventListener(MouseEvent.MOUSE_UP,initDisappear);
			}
		}
		
		private function removeListeners():void
		{
			if(touchEnabled)
			{
				this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN,addNode);
			}else{
				this.stage.removeEventListener(MouseEvent.MOUSE_DOWN,addNode);
			}
		}
		
		private function addNode(e:*):void
		{
			e.stopPropagation();
			var node:Node = new Node(this);
			node.x = e.stageX;
			node.y = e.stageY;
			node.curX = node.prevX = e.stageX<<OPTIMIZER;
			node.curY = node.prevY = e.stageY<<OPTIMIZER;
			node.x = node.curX>>OPTIMIZER;
			node.y = node.curY>>OPTIMIZER;
			
			addChild(node);
			node.addEventListener("removeNode",removeNode);
			lastNode = node;
			if(touchEnabled)
			{
				nodesObject[e.touchPointID]=node;
				node.nodeID = e.touchPointID;
				this.stage.addEventListener(TouchEvent.TOUCH_MOVE,moveNode);
			}else{
				nodesObject[currentNodeId]=node;
				node.nodeID = currentNodeId;
				currentNodeId++;
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE,moveNode);
			}
			trace("node added");
		}
		private function moveNode(e:*):void
		{
			var node:Node;
			if(touchEnabled) node = nodesObject[e.touchPointID];
			else node = lastNode;
			
			node.prevX = node.curX;
			node.prevY = node.curY;
			node.curX = e.stageX<<OPTIMIZER;
			node.curY = e.stageY<<OPTIMIZER;
			node.x = node.curX>>OPTIMIZER;
			node.y = node.curY>>OPTIMIZER;
		}
		private function removeNode(e:Event):void
		{
			var node:Node = (e.currentTarget as Node);
			nodesObject[node.nodeID]=null;
			removeChild(node);
			delete nodesObject[node.nodeID];
			delete (node as Node);
			trace("node deleted");
		}
		public function initDisappear(e:*):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,moveNode);
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE,moveNode);
			
			var diffX:int;
			var diffY:int;
			
			var node:Node;
			if(touchEnabled) node = nodesObject[e.touchPointID];
			else node = lastNode;
			
			diffX = int(e.stageX<<OPTIMIZER) - node.prevX;
			diffY = int(e.stageY<<OPTIMIZER) - node.prevY;
			
			node.angle = int(Math.atan2(diffY,diffX)*RAD2DEG);
			if(node.angle<0)node.angle+=360;
			
			node.speed = Math.sqrt(diffY*diffY+diffX*diffX);
			node.disappear=true;
		}
		private function disappear(e:TimerEvent):void
		{
			for each(var o:* in nodesObject)
			{
				if(!o.disappear)continue;
				
				o.scaleX *= .94;
				o.scaleY = o.scaleX;
				o.prevX=o.curX;
				o.prevY=o.curY;
				o.curX += (COSTABLE[o.angle]*o.speed)/(1<<OPTIMIZER);
				o.curY += (SINTABLE[o.angle]*o.speed)/(1<<OPTIMIZER);
				
				var rand:Number = Math.random();
				o.speed *= ((rand*.1)+.9);
				o.angle += (((1-rand)*40)-20);
				
				if(o.angle>359)o.angle-=359;
				if(o.angle<0)o.angle+=359;
				
				o.x = o.curX>>OPTIMIZER;
				o.y = o.curY>>OPTIMIZER;
				
				if(o.x>stage.stageWidth-(o.width>>1))o.angle=180;
				if(o.x<(o.width>>1))o.angle=0;
				if(o.y>stage.stageHeight-(o.height>>1))o.angle=270;
				if(o.y<(o.height>>1))o.angle=90;
				
				if(o.scaleX<.01) o.dispatchEvent(new Event("removeNode"));
			}
			e.updateAfterEvent();
			animate.reset();
			animate.start();
		}
	}
}