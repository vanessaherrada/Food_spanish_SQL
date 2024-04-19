-- Checando si los datos se cargaron correctamente
SELECT *
FROM food_schema.food_table;

-- 125 participantes
SELECT count(*)
from food_schema.food_table;

-- 76 mujeres (gender=1) y 49 hombres (gender=2) participaron en el estudio
SELECT Gender, COUNT(Gender) 
FROM food_schema.food_table
GROUP BY Gender; 

-- Participantes con los pesos más altos
/* Entre los participantes con los pesos más altos, los tres principales consisten en hombres que cocinan exclusivamente durante las 
 * vacaciones o no cocinan en absoluto. Un individuo caracteriza sus hábitos alimenticios como poco claros, mientras que los otros dos 
 * describen los suyos como saludables, equilibrados o moderados. Además, dos creen que sus hábitos alimenticios han mejorado desde 
 * la universidad, mientras que el tercero los percibe como inalterados. En cuanto a la actividad física, un participante hace ejercicio 
 * diariamente, otro lo hace semanalmente y el restante no proporcionó una respuesta. Es importante destacar que uno de los 
 * participantes nunca verifica los valores nutricionales, mientras que los otros dos lo hacen de manera selectiva, centrándose en 
 * productos específicos.*/
SELECT gender, weight, cook,  diet_current_coded, eating_changes_coded,  exercise, nutritional_check
FROM food_schema.food_table
WHERE weight != -1
ORDER BY weight DESC
LIMIT 3;

/*El 66% de los estudiantes pesa menos de 156 libras, el 54% pesa entre 56 y 210 libras, y el 5% pesa entre 211 y 265 libras. */
select 
	case
		when weight <= 155 then 'Grupo A (<=155 libras)'
		when weight <= 210 then 'Grupo B (156-210 libras)'
		when weight <= 265 then 'Grupo C (211-265 libras)'
		else 'Grupo D (>265 libras)'
	end Grupo_peso,
	count (*) as Frecuencia
from food_schema.food_table ft 
group by Grupo_peso
order by Grupo_peso;

/* La razón más común para consumir comida reconfortante es el aburrimiento, mientras que la menos común es el hambre, 
excluyendo los valores NA (-1) y aquellos que responden ninguno. */
SELECT comfort_food_reasons_coded, COUNT(comfort_food_reasons_coded) AS Frecuencia
FROM food_schema.food_table
WHERE comfort_food_reasons_coded != -1 AND comfort_food_reasons_coded != 9
GROUP BY comfort_food_reasons_coded
ORDER BY Frecuencia DESC;

/* Del total de participantes, que comprende a 125 individuos, el 48% o 60 personas trabajan a tiempo parcial, mientras que 
 * el 43%, equivalente a 54 participantes, no trabajan. Una pequeña parte, el 7% o 9 participantes, no proporcionaron respuesta 
 * a la pregunta. Curiosamente, solo el 1%, representado por 2 participantes, se dedica al empleo a tiempo completo. */
SELECT employment, COUNT(employment) as frecuencia, COUNT(employment) * 100 / (SELECT COUNT(*) from food_schema.food_table) as porcentaje
FROM food_schema.food_table
GROUP BY employment
ORDER BY Frecuencia DESC;

-- 57 de los 125 participantes hacen ejercicio todos los días, 44 lo hacen dos o tres veces por semana, 11 una vez por semana y el resto no respondió.
SELECT exercise, COUNT(exercise) as frecuencia
FROM food_schema.food_table
GROUP BY exercise
ORDER BY frecuencia DESC;

/* La mayoría, compuesta por 73 encuestados, expresa una preferencia por la comida casera. Esto es seguido por 38 participantes que prefieren una 
 * combinación de alimentos comprados en tienda y caseros. Curiosamente, solo 12 participantes indican una preferencia por alimentos exclusivamente 
 * comprados en tiendas.*/
SELECT fav_food, COUNT(fav_food) AS frecuencia
FROM food_schema.food_table
GROUP BY fav_food 
ORDER BY frecuencia DESC;


/* Basado en las respuestas, la cocina italiana emerge como la más consumida entre los participantes, seguida de los platos étnicos. Por otro lado, 
 * la cocina persa parece ser la menos preferida entre los encuestados.*/
with ethnic_food_likeliness as (
	select ethnic_food as probabilidad, count(ethnic_food) as etnica_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
),
greek_food_likeliness as (
	select greek_food as probabilidad, count(greek_food) as griega_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
),
indian_food_likeliness as (
	select indian_food as probabilidad, count(indian_food) as india_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
),
italian_food_likeliness as (
	select italian_food as probabilidad, count(italian_food) as italiana_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
),
persian_food_likeliness as (
	select persian_food as probabilidad, count(persian_food) as persa_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
),
thai_food_likeliness as (
	select thai_food as probabilidad, count(thai_food) as tailandesa_frecuencia
	from food_schema.food_table ft 
	group by probabilidad
)
select ethnic_food_likeliness.probabilidad as probabilidad, ethnic_food_likeliness.etnica_frecuencia , greek_food_likeliness.griega_frecuencia,
indian_food_likeliness.india_frecuencia, italian_food_likeliness.italiana_frecuencia, persian_food_likeliness.persa_frecuencia,
thai_food_likeliness.tailandesa_frecuencia
from greek_food_likeliness
left join ethnic_food_likeliness on ethnic_food_likeliness.probabilidad = greek_food_likeliness.probabilidad
left join indian_food_likeliness on indian_food_likeliness.probabilidad = ethnic_food_likeliness.probabilidad
left join italian_food_likeliness on italian_food_likeliness.probabilidad =  ethnic_food_likeliness.probabilidad
left join persian_food_likeliness on persian_food_likeliness.probabilidad = ethnic_food_likeliness.probabilidad
left join thai_food_likeliness on thai_food_likeliness.probabilidad =  ethnic_food_likeliness.probabilidad
order by ethnic_food_likeliness.probabilidad asc ;


/* El 32% de los estudiantes tienen ingresos superiores a 100,000 USD, lo que representa la mayoría de los participantes.*/
select income, count(income) as frecuencia, count(income) * 100 / (select count(*) 
from food_schema.food_table) as porcentaje
from food_schema.food_table ft 
where income != -1
group by income
order by frecuencia desc;

/* La mayoría, que representa el 60% de los encuestados, prefieren cenar fuera de casa de 1 a 2 veces por semana. 
 * A continuación, el 24% o 19 estudiantes optan por cenar fuera de casa de 2 a 3 veces por semana, mientras que el 12% 
 * nunca elige esta opción. Además, 13 encuestados, representando una minoría, cenan fuera de casa de 3 a 5 veces por 
 * semana, mientras que el 9% lo hace todos los días.*/
select eating_out , count(eating_out) as frecuencia, count(eating_out) * 100 / 
(select count(*) from food_schema.food_table) as porcentaje
from food_schema.food_table ft 
where eating_out != -1
group by eating_out 
order by frecuencia desc;
	
/* La mayoría de los participantes, que comprende el 45%, perciben su peso como justo. Mientras tanto, el 31% se considera 
 * ligeramente sobrepeso, con un porcentaje igual que se siente muy en forma. Curiosamente, el 6% se considera delgado, 
 * mientras que otro 6% se siente con sobrepeso. Solo una pequeña proporción, el 5%, no se categoriza a sí misma utilizando 
 * estos términos. */
select self_perception_weight, count(self_perception_weight)
from food_schema.food_table ft 
where self_perception_weight != -1
group by self_perception_weight
order by count(self_perception_weight) desc ;

