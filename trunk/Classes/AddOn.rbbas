#tag ClassProtected Class AddOnImplements AddonInterface	#tag Method, Flags = &h0		Sub Constructor(name as String, folderItem as FolderItem, enabled as Boolean)		  pName = name		  pFolderItem = folderItem		  pEnabled = enabled		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Sub populateListBoxEntry(listBox as ListBox, addAsFolder as boolean = false)		  // Part of the AddonInterface interface.		  if addAsFolder then		    listBox.AddFolder(pName)		  else		    listBox.AddRow(pName)		  end if		  listBox.cellCheck(listBox.lastIndex, listBox.columnCount - 1) = pEnabled		  listBox.cellTag(listBox.lastIndex, 0) = me		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Sub enable(enable as Boolean)		  pEnabled = enable		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Sub moveItem(enable as Boolean, destinationParent as FolderItem, swapDestinationParent as FolderItem)		  if destinationParent.child(pFolderItem.name).exists then		    dim swapPackage as FolderItem = destinationParent.child(pFolderItem.name)		    dim parameters() as string = array(pFolderItem.name)		    		    // Temporarily move the swap package to the X-Plane folder		    swapPackage.moveFileTo(App.pXPlaneFolder.child(swapPackage.name))		    // Hmm, have to do this next line because RB doesn't seem to update the folderItem correctly when moving it.  Reassign the moved item.		    swapPackage = App.pXPlaneFolder.child(swapPackage.name)		    		    // Move our package		    pFolderItem.moveFileTo(destinationParent.child(pFolderItem.name))		    // Hmm, have to do this next line because RB doesn't seem to update the folderItem correctly when moving it.  Reassign the moved item to the class property		    pFolderItem = destinationParent.child(pFolderItem.name)		    		    // Move the swapped package		    swapPackage.moveFileTo(swapDestinationParent.child(swapPackage.name))		    		    dim d as new MessageDialog		    dim b as MessageDialogButton		    d.icon = MessageDialog.GraphicCaution		    		    if enable then		      d.Message = App.processParameterizedString(wndMain.kEnabledItemSwapped, parameters)		    else		      d.Message = App.processParameterizedString(wndMain.kDisabledItemSwapped, parameters)		    end if		    		    b = d.ShowModal		    		  else		    // Move our package		    pFolderItem.moveFileTo(destinationParent.child(pFolderItem.name))		    // Hmm, have to do this next line because RB doesn't seem to update the folderItem correctly when moving it.  Reassign the moved item to the class property		    pFolderItem = destinationParent.child(pFolderItem.name)		  end if		  		End Sub	#tag EndMethod	#tag Method, Flags = &h0		Sub delete()		  dim parameters() as String		  if pEnabled then		    parameters.append(wndMain.kEnabled)		  else		    parameters.append(wndMain.kDisabled)		  end if		  parameters.append(pName)		  		  if msgbox(App.processParameterizedString(wndMain.kConfirmDelete, parameters), 4) = 6 then		    if pFolderItem.TrashFolder <> nil then		      pFolderItem.moveFileTo(pFolderItem.TrashFolder)		    else		      pFolderItem.moveFileTo(TrashFolder)		    end if		  end if		End Sub	#tag EndMethod	#tag Method, Flags = &h0		 Shared Function extractZipToTemporaryLocation(folderItem as FolderItem) As FolderItem		  dim unzippedFolderItem as FolderItem		  dim zar as ZipArchive		  dim f as FolderItem, e as ZipEntry, i as Integer		  dim packageName as string = folderItem.name.left(folderItem.name.len - 4)		  		  // First, get a uniquely named temporary folderItem.  Unfortunately, this creates a file and we need a folder,		  // so grab its name, delete it and then create a folder with the same name.		  unzippedFolderItem  = getTemporaryFolderItem()		  dim tempFolder as FolderItem = unzippedFolderItem.parent		  dim tempSubfolderName as string = unzippedFolderItem.name		  unzippedFolderItem.delete()		  unzippedFolderItem = tempFolder.child(tempSubfolderName)		  unzippedFolderItem.createAsFolder()		  // Next create a folder with the same name as the zip, but without the file extension.  We use this as the		  // container for the zip extraction so it has a sensible name if we want to move it into the Custom		  // Scenery folder.		  unzippedFolderItem = unzippedFolderItem.child(packageName)		  unzippedFolderItem.createAsFolder()		  		  zar = new ZipArchive		  		  if not zar.Open(folderItem, false) then		    return nil		  end		  		  for i = 1 to zar.EntryCount		    e = zar.Entry(i)		    f = e.MakeDestination(unzippedFolderItem, false)		    		    // Extract, but not MacBinary files		    if not e.Extract(f, false, true) then		      return nil		    end		  next		  		  if not zar.Close() then		    return nil		  end		  		  return unzippedFolderItem		End Function	#tag EndMethod	#tag Method, Flags = &h0		 Shared Function isValid(folderItem as FolderItem) As boolean		  // Subclasses must override this method, return false by default		  return false		End Function	#tag EndMethod	#tag Method, Flags = &h0		 Shared Function searchForAddon(folderItem as FolderItem) As folderItem		  // This is a depth-first recursive search		  		  // First check the passed in folderItem		  if isValid(folderItem) then return folderItem		  		  // Next check the children		  if folderItem.Directory then		    dim i as integer		    for i = 1 to folderItem.count		      dim subSearchFolderItem as FolderItem = searchForAddon(folderItem.trueItem(i))		      if subSearchFolderItem <> nil then return subSearchFolderItem		    next		  end if		  		  // Give up		  return nil		  		End Function	#tag EndMethod	#tag Property, Flags = &h0		pEnabled As Boolean = true	#tag EndProperty	#tag Property, Flags = &h0		pName As String	#tag EndProperty	#tag Property, Flags = &h0		pFolderItem As FolderItem	#tag EndProperty	#tag ViewBehavior		#tag ViewProperty			Name="Name"			Visible=true			Group="ID"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Index"			Visible=true			Group="ID"			InitialValue="-2147483648"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Super"			Visible=true			Group="ID"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Left"			Visible=true			Group="Position"			InitialValue="0"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="Top"			Visible=true			Group="Position"			InitialValue="0"			InheritedFrom="Object"		#tag EndViewProperty		#tag ViewProperty			Name="pEnabled"			Group="Behavior"			InitialValue="true"			Type="Boolean"		#tag EndViewProperty		#tag ViewProperty			Name="pName"			Group="Behavior"			Type="String"			EditorType="MultiLineEditor"		#tag EndViewProperty		#tag ViewProperty			Name="pIndex"			Group="Behavior"			InitialValue="0"			Type="Integer"		#tag EndViewProperty	#tag EndViewBehaviorEnd Class#tag EndClass