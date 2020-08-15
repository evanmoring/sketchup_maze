

$height = 3
$width = 3
$h = 0
while $h < $height  do
	$h+=1
end



$model = Sketchup.active_model
$view = $model.active_view

#add colors
$materials = $model.materials
$material_list = [$materials.add('1'),$materials.add('2'),$materials.add('3'),$materials.add('4'),$materials.add('5'),$materials.add('6'),$materials.add('7'),$materials.add('8')]
$material_list[0].color = [252,108,192] # checking
$material_list[1].color = [139,255,98] # maze
$material_list[2].color = [107,144,229] # choice list
$material_list[3].color = [255,0,0]
$material_list[4].color = [0,255,0]
$material_list[5].color = [0,0,255]
$material_list[6].color = [255,255,255]
$material_list[7].color = [30,30,30] #blank
#$group_grid[10][10].material = $material_list[1]


#create the grid
$group_grid = Array.new($height) {Array.new($width,false)}
$long_length = 24
$short_length = 12
$x_length = $long_length
$y_length = $long_length
$current_x = 0
$current_y = 0
$h = 0
$w = 0

while $w < $width do
	if $w.odd?
		$x_length = $short_length
	else
		$x_length = $long_length
	end
	while $h < $height do

		if $h.odd?
			$y_length = $short_length
		else
			$y_length = $long_length
		end

		group = $model.active_entities.add_group
		$group_grid[$h][$w] = group
		entities = group.entities
		points = [
			Geom::Point3d.new($current_y,   $current_x,   0),
			Geom::Point3d.new($current_y + $y_length, $current_x,   0),
			Geom::Point3d.new($current_y + $y_length, $current_x + $x_length, 0),
			Geom::Point3d.new($current_y,   $current_x + $x_length, 0)
 		]
 		face = entities.add_face(points)
		group.material = $material_list[7]
 		$model.commit_operation
		$current_y += $y_length
		$h +=1
	end
	$current_x += $x_length
	$w += 1
	$h = 0
	$current_y = 0

end

#Create maze
$check_list = []
$prng = Random.new
$current_height = 2*($prng.rand(0..($height-1)/2))
$prng = Random.new
$current_width = 2*($prng.rand(0..($width-1)/2))
$grid = Array.new($height) {Array.new($width,false)}

def check_surrounding 
	print 'cs hw ';print $current_height ; print ' '; puts $current_width
	$grid[$current_height][$current_width]=true	
	if $current_height>0 && !$grid[$current_height-2][$current_width] && !$check_list.include?([$current_height-1,$current_width])
		$check_list.push([$current_height-1,$current_width]) 
		$group_grid[$current_height-1][$current_width].material = $material_list[2]
		take_picture
	end
	if $current_height<$height-1 && !$grid[$current_height+2][$current_width] && !$check_list.include?([$current_height+1,$current_width])
		$check_list.push([$current_height+1,$current_width]) 
		$group_grid[$current_height+1][$current_width].material = $material_list[2]
		take_picture
	end	
	if $current_width>0 && !$grid[$current_height][$current_width-2] && !$check_list.include?([$current_height,$current_width -1])
		$check_list.push([$current_height,$current_width-1]) 
		$group_grid[$current_height][$current_width-1].material = $material_list[2]
		take_picture
	end
	if $current_width<$width-1 && !$grid[$current_height][$current_width+2] && !$check_list.include?([$current_height,$current_width +1])
		$check_list.push([$current_height,$current_width+1]) 
		$group_grid[$current_height][$current_width+1].material = $material_list[2]
		take_picture
	end
	$group_grid[$current_height][$current_width].material = $material_list[1]
	print 'picture count'
	puts $picture_count
	take_picture
end

$picture_count = 0
def take_picture
	#$view.refresh
	picture_name = $picture_count.to_s
	while picture_name.length()< 3
	picture_name = '0'+picture_name
	end
	$view.write_image("#{picture_name}.png")
	$picture_count += 1
end

def choose_next
	
	$prng = Random.new
	$check_choice = $check_list[$prng.rand(0..($check_list.length-1))]
	print 'check choice: '
	print $check_choice
	puts ' '
	$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[0]
	take_picture
	
	
	if $check_choice[0].odd?
		if !$grid[$check_choice[0]+1][$check_choice[1]]
			$grid[$check_choice[0]+1][$check_choice[1]]=true
			$grid[$check_choice[0]][$check_choice[1]]=true
			$current_height = $check_choice[0]+1
			$current_width = $check_choice[1]
			$group_grid[$current_height][$current_width].material = $material_list[0]
			take_picture
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[1]
			take_picture
			$check_list.delete($check_choice)
	$group_grid[$current_height][$current_width].material = $material_list[0]
			check_surrounding
		elsif !$grid[$check_choice[0]-1][$check_choice[1]]
			$grid[$check_choice[0]-1][$check_choice[1]]=true
			$grid[$check_choice[0]][$check_choice[1]]=true
			$current_height = $check_choice[0]-1
			$current_width = $check_choice[1]
			$group_grid[$current_height][$current_width].material = $material_list[0]
			take_picture
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[1]
			take_picture
			$check_list.delete($check_choice)
	$group_grid[$current_height][$current_width].material = $material_list[0]
			check_surrounding
		else
			$check_list.delete($check_choice)
			#$group_grid[$current_height][$current_width].material = $material_list[0]
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[7]
			take_picture
		end
	else
		if !$grid[$check_choice[0]][$check_choice[1]+1]
			$grid[$check_choice[0]][$check_choice[1]+1]=true
			$grid[$check_choice[0]][$check_choice[1]]=true
			$current_height = $check_choice[0]
			$current_width = $check_choice[1]+1
			$group_grid[$current_height][$current_width].material = $material_list[0]
			take_picture
			
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[1]
			take_picture
			$check_list.delete($check_choice)
	$group_grid[$current_height][$current_width].material = $material_list[0]
			check_surrounding
		elsif !$grid[$check_choice[0]][$check_choice[1]-1]
			$grid[$check_choice[0]][$check_choice[1]-1]=true
			$grid[$check_choice[0]][$check_choice[1]]=true
			$current_height = $check_choice[0]
			$current_width = $check_choice[1]-1
			$group_grid[$current_height][$current_width].material = $material_list[0]
			take_picture
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[1]
			take_picture
			$check_list.delete($check_choice)
	$group_grid[$current_height][$current_width].material = $material_list[0]
			check_surrounding
		else
			$group_grid[$check_choice[0]][$check_choice[1]].material = $material_list[7]
			$check_list.delete($check_choice)
			take_picture
			#$group_grid[$current_height][$current_width].material = $material_list[0]
		end
	end
	
	
end
take_picture
$group_grid[$current_height][$current_width].material = $material_list[0]
take_picture
check_surrounding

$check = 0

while $check_list.length > 0 && $check < 200 do 
	choose_next
	$check +=1
end

puts $check

