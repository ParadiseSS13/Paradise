import os, time
import pymysql.cursors
from beautifultable import BeautifulTable

host = 'localhost'
port = 3306
username = 'root'
password = '123456'
database = 'feedback'
prefix = 'ss13_'

def main():
	conn = pymysql.connect(
		host = host,
		port = port,
		user = username,
		password = password,
		database = database
	)

	if os.name == 'nt':
		clear = lambda: os.system('cls')
	else:
		clear = lambda: os.system('clear')

	def see_whitelist():

		users = BeautifulTable()
		users.column_headers = ["id", "ckey", "job"]
		
		try:
			with conn.cursor() as cursor:
				sql = "SELECT id, ckey, job FROM {}whitelist".format(prefix)
				cursor.execute(sql)
				result = cursor.fetchall()
				for p in range(len(result)):
					users.append_row([result[p][0], result[p][1], result[p][2]])
		
		finally:
			clear()
			print(users)
	
	def insert_whitelist(ckey, jobs):

		user = BeautifulTable()
		user.column_headers = ["ckey", "job"]

		try:
			with conn.cursor() as cursor:
				sql = "INSERT INTO `{}whitelist` (`ckey`, `job`) VALUES (%s, %s)".format(prefix)
				cursor.execute(sql, (ckey, jobs))
				user.append_row([ckey, jobs])
			
			conn.commit()
		finally:
			clear()
			print(user)

	def update():
		
		try:
			with conn.cursor() as cursor:
				sql = "ALTER TABLE `ss13_whitelist` DROP `id`"
				cursor.execute(sql)
			with conn.cursor() as cursor:
				sql = "ALTER TABLE `ss13_whitelist` AUTO_INCREMENT = 1"
				cursor.execute(sql)
			with conn.cursor() as cursor:
				sql = "ALTER TABLE `ss13_whitelist` ADD `id` int UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST"
				cursor.execute(sql)
			conn.commit()
		finally:
			menu()

	def remove_whitelist(uid):

		try:
			with conn.cursor() as cursor:
				sql = "DELETE FROM `{}whitelist` WHERE id='%s'".format(prefix)
				cursor.execute(sql, (uid))
			
			conn.commit()
		finally:
			update()
			#clear()
			#menu_back()

	def menu_back():
		b = input("Inserta - x - Para volver atrás: ")
		if b == "x":
			menu()
		else:
			menu_back()

	def menu_remove():
		clear()
		see_whitelist()
		sure = input("Seguro que quieres eliminar a alguien de la whitelist? [Y/N]\n")
		if(id(sure) == id("y") or id(sure) == id("Y")):
			try:
				question = int(input("Introduce la ID del usuario que quieres eliminar: "))
				remove_whitelist(question)
			except ValueError:
				menu_remove()
		elif(id(sure) == id("n") or id(sure) == id("N")):
			menu()
		else:
			menu_remove()

	def menu_insert():
		clear()
		print("------------ WHITELIST -------------")
		print("Los jobs deben estar separados por coma.")
		print("Jobs que actualmente están en la whitelist:")
		print("------------------------------------")
		print("[ ] Captain\n[ ] Head of Personnel\n[ ] Head of Security\n[ ] Chief Engineer\n[ ] Research Director\n[ ] Chief Medical Officer\n[ ] Nanotrasen Representative\n[ ] AI\n[ ] Blueshield\n[ ] Cyborg\n[ ] Magistrate\n[ ] Warden")
		print("------------------------------------")
		ckey = input("Introduce el ckey: ").replace(" ", "")
		jobs = input("Introduce los trabajos: ").replace(", ", ",").replace(" , ", ",").replace(" ,", ",").rstrip(',')
		if ckey is '' or jobs is '':
			menu_insert()
		insert_whitelist(ckey, jobs)

	def menu():
		clear()
		choice = True
		while choice:
			print("------------ WHITELIST -------------")
			print("1- Añadir a la whitelist")
			print("2- Eliminar de la whitelist")
			print("3- Ver la whitelist")
			print("4- Salir")
			print("------------------------------------")

			choice = input ("Elige una opcion: ")

			if choice == "4":
				conn.close()
				exit()
			elif choice == "3":
				see_whitelist()
				menu_back()
			elif choice == "2":
				menu_remove()
			elif choice == "1":
				menu_insert()
				menu_back()
			else:
				time.sleep(0.1)
				clear()
				menu()

	menu()
main()