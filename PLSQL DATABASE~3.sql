set SERVEROUTPUT ON
declare
    cursor c_test is
        select rgt.registrationno , count(ct.chapter)
        from questiontest qt
        join questionbank qb
        on qt.questionid = qb.questionid
        join registration rgt
        on qt.registrationno = rgt.registrationno
        join chapter ct
        on qb.subjectcode = ct.subjectcode
        where qt.registrationno = 300006;
begin
    for rec_test in c_test loop
        dbms_output.put_line('test'||rec_test.chapter);
    end loop;
end;




 create or replace  function checking_score ( p_registrationno registration.registrationno%type)return type_count is
            cursor c_get_ans(p_registrationno registration.registrationno%type) is
                    select testanswer,answer 
                    from questiontest q join registration r on q.registrationno = r.registrationno
                    where  q.registrationno = p_registrationno and ;
            v_result boolean :=false;
            v_count_correct number:=0;
            v_count_false number :=0;
            begin
                    for rec_check in c_get_ans(p_registrationno) loop
                            v_result := valid_answer (rec_check.testanswer,rec_check.answer);
                            if(v_result = true) then
                                    v_count_correct := v_count_correct+1;
                            else 
                                    v_count_false := v_count_false+1;
                            end if;
                    end loop;
                            return type_count(v_count_correct,v_count_false);
    end  checking_score;

  create or replace   function valid_answer(p_answer_user questiontest.answer%type,
                                            p_answer_test questiontest.testanswer%type) return boolean is
            begin
                    if p_answer_user = p_answer_test then
                        return true;
                    else     
                         return false;
                    end if; 
    end valid_answer;
    
    

select rgt.registrationno , ct.chapter
from questiontest qt
join registration rgt
on qt.registrationno = rgt.registrationno
join chapter ct
on qb.subjectcode = ct.subjectcode
where qt.registrationno = 300006 and ;


select rgt.registrationno , ct.chapter
from questiontest qt
join questionbank qb
on qt.questionid = qb.questionid
join registration rgt
on qt.registrationno = rgt.registrationno
join chapter ct
on qb.subjectcode = ct.subjectcode
where qt.registrationno = 300006;
--group by rgt.registrationno,ct.numquestions,ct.chapter,ct.subjectcode 
--order by rgt.registrationno,ct.chapter,ct.numquestions,ct.subjectcode;

--group by rgt.registrationno,ct.numquestions,ct.chapter,ct.subjectcode 
--order by rgt.registrationno,ct.chapter,ct.numquestions,ct.subjectcode;

 , ct.numquestions,count(qt.questionid) --count correct
as "correct number",ct.subjectcode