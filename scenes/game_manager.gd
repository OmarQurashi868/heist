extends Node3D

var team_scores = {"red": 0, "blue": 0, "green": 0, "yellow": 0}

func add_score(team):
	team_scores[team] += 1
	print(team_scores)
