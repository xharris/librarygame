# TODOS

- Add behavior: Move away if on the same cell as a station
- Add behavior: Read book
	- ROLE == patron
	- give actor a read_count_goal (# of books they want to read)
		- Extra: can have mod NO_BOOK_REPEATS if they don't read the same book twice (based on title)
- Game UI: Make it cute

# IDEAS

- MenuBar Books
	- List of checkboxes
		- Enabled: chance to gain a new book (delivery) every X seconds for $Y 
			- Y increases with # number of genres book has
	- Each checkbox is a book genre
	- Multiple checked adds chance a book with multiple genres will be delivered

# build a library

start with a small room and a box of random books

currency: money

patron stats:

possible goals:
- have X amount of daily patrons
- avg happiness > X for X days

shop:
- staff
- contractor
- pets?
- structures

actor:
- ALL
	- happiness
		- will cause actor to leave/quit if low enough
	- likes (activity)
		- peforming activity increases happiness
		- 
	- dislikes
		- exposure to dislikes lowers happiness
	- age
		- effects sprite appearance
		- effects likes
- patron
	- spawn rate: ???
	- will leave when happiness is 0 for an entire cycle
	- hunger
		- will cause patron to leave early if low enough
- staff
	- schedule: work, break, off
	- being on break will slowly replenish happiness
	- happiness resets after returning from 'off' (full - slightly full)
- service
	- staff but expires after X cycles
	- schedule: work
- pet?

station:
- ALL
	- can have hp/durability
		- decreases after being used
		- increases via maintenance
	- has inventory
	- can hold X patrons for Y-Z time 
	- can be operated by X patrons for Y time
	- can cost X dollars to operate
- wall
	- 0 operation
	- hp does not deplete?
- station (chair, vending machine, security check)
- storage (bookshelf)
- door
	- connects neighboring tiles with NavigationLink2D for actors that have access (add links to actor)

making it fun:
- themed structures
- scenarios (starting layout)
	- small library (one staff, box w/books, thats it)
	- torn down, huge library
	- unpopular scary book store
	- small research center (needs more books and organization)
- strange rare patrons (likes)
	- goes to a section of the library and plays loud music
	- sleeps in a chair for a long time
	- stealing

polish:
- activity/read
	- chance that patron will keep book instead of storing it
	- need library card to take book home
- doors/gates
	- toggle access based on actorType

other:
- https://github.com/airstruck/knife/blob/master/readme/chain.md
- https://www.gamedeveloper.com/programming/toward-more-realistic-pathfinding

