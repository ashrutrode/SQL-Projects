--9/23/23 @ 7:29 pm: Going through all the questions on this website: https://www.sql-practice.com/

	--Easy Questions
		
		--1. Show first name, last name, and gender of patients whose gender is 'M'
		SELECT first_name, last_name, gender FROM patients WHERE gender="M";

		--2. Show first name and last name of patients who does not have allergies. (null)
		SELECT
		first_name, 
		last_name
		FROM patients
		WHERE allergies is NULL;

		--3. Show first name of patients that start with the letter 'C'
		SELECT 
			first_name 
		FROM 
			patients 
		WHERE 
			first_name LIKE "C%";

		--4. Show first name and last name of patients that weight within the range of 100 to 120 (inclusive)
		SELECT
			first_name, 
		    last_name
		FROM 
			patients
		WHERE 
			weight >= 100 and weight <= 120;

		--5. Update the patients table for the allergies column. If the patient's allergies is null then replace it with 'NKA'
		UPDATE 
			patients
		SET 
			allergies="NKA"
		WHERE 
			allergies is NULL;

		--6. Show first name and last name concatinated into one column to show their full name.
		SELECT 
			first_name || " " || last_name as full_name
		FROM
			patients;

		--7. Show first name, last name, and the full province name of each patient.
		--Example: 'Ontario' instead of 'ON'
		SELECT
			first_name, 
		    last_name, 
		    province_names.province_name
		FROM 
			patients
		inner join 
			province_names
		on patients.province_id=province_names.province_id;

		--8. Show how many patients have a birth_date with 2010 as the birth year.
		SELECT COUNT(birth_date) FROM patients WHERE birth_date LIKE "2010%";

		--9. Show the first_name, last_name, and height of the patient with the greatest height.
		SELECT
			first_name,
		    last_name,
		    height
		FROM
			patients
		ORDER BY height DESC
		LIMIT 1;

		--10. Show all columns for patients who have one of the following patient_ids:
		--1,45,534,879,1000
		SELECT * 
		FROM patients
		WHERE patient_id IN (1,45,534,879,1000);

		--11. Show the total number of admissions
		SELECT COUNT(*) AS total_admissions
		FROM admissions;

		--12. Show all the columns from admissions where the patient was admitted and discharged on the same day.
		SELECT * 
		FROM admissions 
		WHERE admission_date=discharge_date;

		--13. Show the patient id and the total number of admissions for patient_id 579.
		SELECT 
			patient_id, 
		    COUNT(*)
		FROM admissions 
		WHERE patient_id=579;

		--14. Based on the cities that our patients live in, show unique cities that are in province_id 'NS'?
		SELECT DISTINcT(city) 
		FROM patients 
		WHERE province_id = "NS";

		--15. Write a query to find the first_name, last name and birth date of patients who has height greater than 160 and weight greater than 70
		SELECT 
			first_name,
		    last_name,
		    birth_date
		FROM patients
		WHERE 
			height > 160 AND weight > 70;

		--16. Write a query to find list of patients first_name, last_name, and allergies from Hamilton where allergies are not null
		SELECT 
			first_name, last_name, allergies
		FROM patients 
		WHERE city = 'Hamilton' AND allergies IS NOT NULL;

		--17. Based on cities where our patient lives in, write a query to display the list of unique city 
		--starting with a vowel (a, e, i, o, u). Show the result order in ascending by city.
		SELECT DISTINCT(city) 
		FROM patients
		WHERE 
			city LIKE "a%" OR 
		    city LIKE "e%" OR
		    city LIKE "i%" OR 
		    city LIKE "o%" OR 
		    city LIKE "u%"
		ORDER BY city ASC

	--Medium Questions
		
		--18. Show unique birth years from patients and order them by ascending.
		SELECT DISTINCT(YEAR(birth_date)) AS distinct_birth_year 
		FROM patients
		ORDER BY distinct_birth_year;

		--19. Show unique first names from the patients table which only occurs once in the list.
		--For example, if two or more people are named 'John' in the first_name column then don't 
		--include their name in the output list. If only 1 person is named 'Leo' then include them in the output.
		SELECT first_name
		FROM patients
		GROUP BY first_name
		HAVING COUNT(first_name) = 1

		--20.Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
		SELECT patient_id, first_name
		FROM patients
		WHERE first_name LIKE "s%s" AND LEN(first_name) >= 6;

		--21.Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
		--Primary diagnosis is stored in the admissions table.
		SELECT patients.patient_id, first_name, last_name
		FROM patients
		JOIN admissions ON patients.patient_id = admissions.patient_id
		WHERE diagnosis = 'Dementia';

		--22. Display every patient's first_name. Order the list by the length of each name and then by alphbetically
		SELECT first_name 
		FROM patients
		ORDER BY len(first_name), first_name;

		--23. Show the total amount of male patients and the total amount of female patients in the patients table.
		--Display the two results in the same row.
		SELECT 
		(SELECT COUNT(*) FROM patients WHERE gender="M") as male_patients, 
	    (SELECT COUNT(*) FROM patients WHERE gender="F") as female_patients;

	    --24. Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. 
	    --Show results ordered ascending by allergies then by first_name then by last_name.
	    SELECT 
			first_name, 
		    last_name, 
		    allergies 
		FROM patients
		WHERE allergies IN ('Penicillin', 'Morphine')
		ORDER BY allergies, first_name, last_name;

		--25. Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
		SELECT 
			patient_id, 
		    diagnosis 
		FROM admissions
		GROUP BY patient_id, diagnosis
		HAVING COUNT(patient_id) > 1

		--26. Show the city and the total number of patients in the city.
		--Order from most to least patients and then by city name ascending.
		SELECT city, count(*) 
		FROM patients
		GROUP BY city
		ORder By Count(*) DESC, city;

		--27. Show first name, last name and role of every person that is either patient or doctor.
		--The roles are either "Patient" or "Doctor"
		SELECT first_name, last_name, "patient" AS role FROM patients
		UNION ALL 
		SELECT first_name, last_name, "doctor" AS role FROM doctors;

		--28. Show all allergies ordered by popularity. Remove NULL values from query.
		SELECT allergies, count(*) AS total_diagnoses
		FROM patients
		WHERE allergies is NOT NULL
		GROUP BY allergies
		ORDER BY COUNT(*) DESC;

		--29. Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. 
		--Sort the list starting from the earliest birth_date.
		SELECT first_name, last_name, birth_date 
		FROM patients
		WHERE 
			YEAR(birth_date) >= 1970 AND 
		    YEAR(birth_date) <= 1979
		ORDER BY birth_date;

		--30. We want to display each patient's full name in a single column. Their last_name in all upper letters must 
		--appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. 
		--Order the list by the first_name in decending order
		--EX: SMITH,jane
		SELECT 
			concat(UPPER(last_name),",",LOWER(first_name)) AS full_name 
		FROM patients
		ORDER BY first_name DESC;

		--31. Show the province_id(s), sum of height; where the total sum of its patient's 
		--height is greater than or equal to 7,000.
		SELECT 
			province_id, 
		    SUM(height)
		FROM patients
		GROUP BY province_id
		HAVING SUM(height) > 7000;

		--32. Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'
		SELECT 
			MAX(weight)-MIN(weight) 
		FROM patients
		WHERE last_name = 'Maroni';

		--33. Show all of the days of the month (1-31) and how many admission_dates occurred on that day. 
		--Sort by the day with most admissions to least admissions.
		SELECT 
			DAY(admission_date) AS day_, COUNT(*) 
		FROM admissions
		GROUP BY day_
		ORDER BY COUNT(*) DESC;

		--34. Show all columns for patient_id 542's most recent admission_date.
		SELECT * 
		FROM admissions
		WHERE patient_id=542
		ORDER BY discharge_date DESC
		LIMIT 1;

		--35. Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
			--1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
			--2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
		SELECT patient_id, attending_doctor_id, diagnosis 
		FROM admissions
		WHERE 
			(patient_id%2=1 AND attending_doctor_id IN (1,5,19)) OR 
		    (attending_doctor_id LIKE '%2%' AND LEN(patient_id)=3);

		--36. Show first_name, last_name, and the total number of admissions attended for each doctor.
		--Every admission has been attended by a doctor.
		SELECT 
			doctors.first_name, 
		    doctors.last_name, 
		    COUNT(*) 
		FROM admissions
		JOIN doctors ON admissions.attending_doctor_id=doctors.doctor_id
		GROUP BY attending_doctor_id;

		--37. For each doctor, display their id, full name, and the first and last admission date they attended.
		SELECT 
			doctor_id,
		    CONCAT(first_name, " ", last_name) AS full_name,
		    MIN(admission_date) as first_admission_date,
		    MAX(admission_date) as last_admission_date
		FROM admissions
		JOIN doctors ON admissions.attending_doctor_id=doctors.doctor_id
		GROUP BY full_name
		ORDER BY attending_doctor_id;

		--38. Display the total amount of patients for each province. Order by descending.
		SELECT
		    province_names.province_name,
		    COUNT(*) AS total_number_patients
		FROM patients
		JOIN province_names ON patients.province_id = province_names.province_id
		GROUP BY(province_names.province_name)
		ORDER BY total_number_patients DESC;

		--39. For every admission, display the patient's full name, their admission diagnosis, 
		--and their doctor's full name who diagnosed their problem.
		SELECT 
			CONCAT(patients.first_name, " ", patients.last_name) AS full_name,
		    diagnosis,
		    CONCAT(doctors.first_name, " ", doctors.last_name) AS doctor_full_name
		FROM admissions
			JOIN patients ON patients.patient_id = admissions.patient_id
			JOIN doctors ON admissions.attending_doctor_id=doctors.doctor_id;

		--40. Display the number of duplicate patients based on their first_name and last_name.
		SELECT first_name, last_name, COUNT(*) 
		FROM patients
		GROUp BY first_name, last_name
		HAVING COUNT(*) > 1;

		--41. Display patient's full name,
			--height in the units feet rounded to 1 decimal,
			--weight in the unit pounds rounded to 0 decimals,
			--birth_date,
			--gender non abbreviated.

			--Convert CM to feet by dividing by 30.48.
			--Convert KG to pounds by multiplying by 2.205.
		SELECT 
			CONCAT(first_name, " ", last_name) AS full_name,
		    ROUND(height/30.48, 1) AS height_feet,
		    ROUND(weight*2.205, 0) AS weight_pounds,
		    birth_date,
		    CASE 
		    	WHEN gender = 'M' THEN 'Male'
		        WHEN gender = 'F' THEN 'Female'
		    END AS gender
		FROM patients;

		--42. Show patient_id, first_name, last_name from patients whose does not have 
		--any records in the admissions table. (Their patient_id does not exist 
		--in any admissions.patient_id rows.)
		SELECT 
			patients.patient_id, 
		    patients.first_name, 
		    patients.last_name
		FROM patients
		LEFT JOIN admissions ON patients.patient_id = admissions.patient_id
		WHERE admissions.patient_id is NULL;

	--Hard Questions

		--43. Show all of the patients grouped into weight groups.
		--Show the total amount of patients in each weight group.
		--Order the list by the weight group decending.
		--For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.
		SELECT weight_group, COUNT(t.weight_group) 
		FROM (
		  SELECT 
		    CASE
		      WHEN weight BETWEEN 0 and 9 THEN '0'
		      WHEN weight BETWEEN 10 and 19 THEN '10'
		      WHEN weight BETWEEN 20 and 29 THEN '20'
		      WHEN weight BETWEEN 30 and 39 THEN '30'
		      WHEN weight BETWEEN 40 and 49 THEN '40'
		      WHEN weight BETWEEN 50 and 59 THEN '50'
		      WHEN weight BETWEEN 60 and 69 THEN '60'
		      WHEN weight BETWEEN 70 and 79 THEN '70'
		      WHEN weight BETWEEN 80 and 89 THEN '80'
		      WHEN weight BETWEEN 90 and 99 THEN '90'
		      WHEN weight BETWEEN 100 and 109 THEN '100'
		      WHEN weight BETWEEN 110 and 119 THEN '110'
		      WHEN weight BETWEEN 120 and 129 THEN '120'
		      WHEN weight BETWEEN 130 and 139 THEN '130'
		      WHEN weight BETWEEN 140 and 149 THEN '140'
		    END AS weight_group,
		  	weight
		  FROM patients) t
		GROUP BY weight_group
		ORDER BY CAST(weight_group AS INT) DESC;

		/*SELECT 
		   (SELECT COUNT(*) 
		  	FROM patients
		 	WHERE weight > 0 and weight < 10) AS weight_class,
		   (SELECT COUNT(*) 
		    FROM patients
		    WHERE weight >= 10 and weight < 19) AS weight_class_1;*/

		/*SELECT 
			0 AS weight_group, 
		       	    CASE
		   		WHEN weight > 0 AND weight < 10 THEN SUM(*)
		    END AS total_weight,
		    SUM(weight),
		    *
		FROM patients
		GROUP BY weight;*/

		--44. Show patient_id, weight, height, isObese from the patients table.
		--Display isObese as a boolean 0 or 1.
		--Obese is defined as weight(kg)/(height(m)2) >= 30.
		--weight is in units kg.
		--height is in units cm.
		SELECT 
			patient_id,
		    weight,
		    height,
		    CASE
		    	WHEN weight/SQUARE(CAST(height AS float)/100) >= 30 THEN 1
		        ELSE 0
		    END AS isObese
		FROM patients;

		--45. Show patient_id, first_name, last_name, and attending doctor's specialty.
		--Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
		--Check patients, admissions, and doctors tables for required information.
		SELECT 
			patients.patient_id,
		    patients.first_name,
		    patients.last_name,
		    specialty
		FROM patients
			JOIN admissions ON admissions.patient_id=patients.patient_id
		    JOIN doctors on attending_doctor_id=doctor_id
		WHERE diagnosis='Epilepsy' AND doctors.first_name='Lisa';

		--46. All patients who have gone through admissions, can see their medical documents on our site. 
		--Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
		--The password must be the following, in order:
			--1. patient_id
			--2. the numerical length of patient's last_name
			--3. year of patient's birth_date
		SELECT 
		    DISTINCT patients.patient_id,
		    CONCAT(patients.patient_id, LEN(last_name), YEAR(birth_date)) as temporary_password
		FROM patients
		JOIN admissions ON patients.patient_id=admissions.patient_id;

		--47. Each admission costs $50 for patients without insurance, and $10 for patients with insurance. 
		--All patients with an even patient_id have insurance. Give each patient a 'Yes' if they have insurance, 
		--and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
		SELECT 
		    CASE
		        WHEN patient_id%2=0 THEN "Yes"
		        ELSE "No"
		    END AS has_insurance,
		    CASE
		    	WHEN patient_id%2=0 THEN COUNT(*)*10
		        ELSE COUNT(*)*50
		    END AS admission_total
		FROM admissions
		GROUP BY has_insurance

		--48. Show the provinces that has more patients identified as 'M' than 'F'. 
		--Must only show full province_name
		SELECT province_name
		FROM
		(
		    SELECT
		        province_id,
		  		CASE
		          WHEN 
		              SUM(CASE WHEN gender='M' THEN 1 END) > 
		              SUM(CASE WHEN gender='F' THEN 1 END)
		              THEN 'More Men'
		              ELSE 'More women'
		          END
		        AS men_more
		    FROM patients 
		    GROUP BY province_id
		) AS t
		JOIN province_names ON t.province_id = province_names.province_id
		WHERE men_more='More Men';

		--49. We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
		-- First_name contains an 'r' after the first two letters.
		-- Identifies their gender as 'F'
		-- Born in February, May, or December
		-- Their weight would be between 60kg and 80kg
		-- Their patient_id is an odd number
		-- They are from the city 'Kingston'
		SELECT * 
		FROM patients
		WHERE 
			first_name LIKE "__r%" AND 
		    gender='F' AND
		    MONTH(birth_date) IN (2, 5, 12) AND
		    weight BETWEEN 60 AND 80 AND
		    patient_id%2=1 AND
		    city='Kingston';

		--50. Show the percent of patients that have 'M' as their gender. 
		--Round the answer to the nearest hundreth number and in percent form.
		SELECT 
		    CONCAT(ROUND(
		    	(
		      	CAST((SELECT COUNT(*) FROM patients WHERE gender="M") AS FLOAT) 
		    		/ 
		    	CAST (COUNT(*) AS FLOAT)
		    )*100, 2), "%") AS percent_of_male_patients
		FROM patients;

		--51. For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
		SELECT 
			admission_date, 
		    COUNT(*) AS num_admissions,
		    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY admission_date)
		FROM admissions
		GROUP BY admission_date;

		--52. Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
		SELECT province_name FROM
		(SELECT 'Ontario' AS province_name, 1 as o
		UNION ALL
		SELECT province_name, 2 AS o 
		FROM province_names 
		WHERE province_name != 'Ontario' 
		ORDER BY o, province_name);

		--53. We need a breakdown for the total amount of admissions each doctor has started each year. 
		--Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.
		SELECT 
			doctor_id,
		    CONCAT(first_name," ", last_name) AS doctor_full_name,
		    specialty,
		    YEAR(admission_date), 
		    COUNT(*) 
		FROM admissions
		JOIN doctors ON admissions.attending_doctor_id = doctors.doctor_id
		GROUP BY attending_doctor_id, year(admission_date);

--9/22/23 @ 12:41 pm: Trying some basic queries at this website: https://www.sql-practice.com/
	SELECT * FROM patients; -- all patients
	SELECT * FROM patients LIMIT 10; -- limit to 10
	SELECT * FROM patients WHERE gender="M"; -- limit to only M gender
	SELECT * FROM patients WHERE birth_date LIKE "1963%"; -- limit to only patients born in 1963
	SELECT COUNT(*) FROM patients WHERE birth_date LIKE "1963%" -- count ^
	SELECT * FROM patients WHERE birth_date < '1970-01-01' -- select before a certain date

	--births born after certain date ordered by high to low
	SELECT * 
	FROM patients
	WHERE birth_date >= '2000-01-01'
	ORDER BY birth_date DESC

	--select the 10 heaviest patients
	SELECT * 
	FROM patients
	ORDER BY weight DESC
	LIMIT 10;

	--select the 10 oldest patients who have an allergy to eggs
	SELECT * 
	FROM patients
	WHERE allergies="Eggs"
	ORDER BY birth_date
	LIMIT 10;

	--find all discrete allergies
	SELECT DISTINCT allergies from patients;

	--count number of distinct cities
	SELECT COUNT(DISTINCT city) FROM patients;

	--9/26/23 @ 12:41 pm: Find the second highest patient_id
	SELECT patient_id 
	FROM patients
	ORDER BY patient_id DESC
	LIMIT 1, 1;






