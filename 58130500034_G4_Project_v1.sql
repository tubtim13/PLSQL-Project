    -- type declaration
   create or replace  type type_count is object(
            v_correct number,
            v_false number 
    );

create or replace package package_analysis is
    procedure analyze_test(p_registrationno questiontest.questionid%type);
    procedure analyze_test(p_testdate registration.testdate%TYPE,
                                                            p_subjectcode  registration.subjectcode%TYPE);
    procedure analyze_test(p_subjectcode  registration.subjectcode%TYPE); 
end package_analysis;

create or replace package body package_analysis is
    --forward declaration block
     procedure check_answer(p_questionno questiontest.questionid%type);
     function checking_score ( p_registrationno registration.registrationno%type)return type_count;
     function true_false_answer(p_answer_user questiontest.answer%type,
                                            p_answer_test questiontest.testanswer%type) return boolean;
     procedure get_answer(p_questionno questiontest.questionid%type := null,p_registrationno registration.registrationno%type := null);                                 
    procedure sumary_question (p_questionid questionbank.questionid%type);
    
    -- implementation block    
    procedure analyze_test(p_registrationno questiontest.questionid%type)IS
            type regis_rec is record ( v_prefix      tester.prefix%type,
                                                    v_firstname   tester.firstname%type,
                                                    v_lastname    tester.lastname%type );
 
            cursor c_get_question (p_reg_no registration.registrationno%type )is
                    select  qt.no,qb.question,qt.questionid
                    from questionbank qb join (select no, questionid 
                                                            from questiontest
                                                            where registrationno = p_reg_no) qt
                    on qb.questionid = qt.questionid
                    order by qt.no;
            v_regis regis_rec;
            v_testanswer questiontest.testanswer%type;
            v_answer questiontest.answer%type;
            v_result boolean :=false;
            v_score type_count;
            begin 
                select t.prefix, t.firstname, t.lastname into  v_regis
                from tester  t  join  registration r  on t.testerno = r.testerno 
                where  r.registrationno = p_registrationno;  
                dbms_output.put_line('Name :  '|| v_regis.v_firstname||' '||v_regis.v_lastname );
                
                 v_score := checking_score(p_registrationno);
                dbms_output.put_line('Your score is '||v_score.v_correct||', incorrect'||v_score.v_false);
                dbms_output.put_line('');
                                        
                for rec_qeustion in c_get_question(p_registrationno) loop 
                        dbms_output.put_line('No.' ||rec_qeustion.NO ||' '||rec_qeustion.question);
                        get_answer(rec_qeustion.questionid,p_registrationno);

                        select q.answer,q.testanswer into v_answer,v_testanswer 
                        from  registration r 
                        join questiontest q on q.registrationno = r.registrationno  
                        where  r.registrationno = p_registrationno and q.questionid = rec_qeustion.questionid; 
                        
                         v_result := true_false_answer (v_testanswer,v_answer);
                                if(v_result = true) then
                                    dbms_output.put_line('Your answer ' ||v_testanswer||' is correct');
                                else 
                                     dbms_output.put_line('Your answer ' ||v_testanswer|| 'is incorrect, the correct answer is '||v_answer);
                                end if;      
                        sumary_question(rec_qeustion.questionid);
                        dbms_output.put_line('');
                end loop;
        end analyze_test ; 
    
    procedure analyze_test(p_testdate registration.testdate%TYPE,
                                        p_subjectcode  registration.subjectcode%TYPE)is
                                                    
        cursor c_get_question( p_testdate registration.testdate%TYPE,
                                          p_subjectcode  registration.subjectcode%TYPE) is
                select DISTINCT q.questionid,qb.question
                from registration r
                join questiontest q
                on q.registrationno = r.registrationno
                join questionbank qb on qb.questionid = q.questionid
                where lower(r.subjectcode) = lower(p_subjectcode) and lower(r.testdate) = lower(p_testdate);
                
        v_no number := 0;
        begin
                dbms_output.put_line('Subject : ' ||p_subjectcode ||', Test Date '||p_testdate);
                dbms_output.put_line('');
                for rec_qeustion in c_get_question(p_testdate,p_subjectcode) loop
                        v_no := v_no+1;
                        dbms_output.put_line('No.' ||v_no ||' '||rec_qeustion.question);
                        get_answer(rec_qeustion.questionid);
                        check_answer(rec_qeustion.questionid);
                        sumary_question(rec_qeustion.questionid);
                        dbms_output.put_line('');
                end loop;
    end analyze_test;
    
    procedure analyze_test(p_subjectcode  registration.subjectcode%TYPE)is              
            cursor c_chap_cur(p_subjectcode subject.subjectcode%type) IS
                    select c.chapter
                    from subject s 
                    join chapter c
                    on s.subjectcode = c.subjectcode 
                    where lower(c.subjectcode) = lower(p_subjectcode)
                    order by c.chapter;
                
            cursor c_question_cur(p_chap chapter.chapter%type)IS
                    select question,questionid
                    from questionbank
                    where chapter = p_chap;
            v_count number :=0;
            v_sub_name subject.subjectname%type;
            v_subjectname subject.subjectname%TYPE;
            v_chapter  chapter.chapter%TYPE;
            v_question questionbank.question%TYPE;
            
            begin
                    select subjectname into v_sub_name from subject where  lower(subjectcode) = lower(p_subjectcode);
                    dbms_output.put_line('Sucject : ' || v_sub_name);
                            
                    for rec_chapter in c_chap_cur(p_subjectcode) loop
                            v_count  := 0;
                            dbms_output.put_line('Chapter: ' || rec_chapter.chapter);
                            dbms_output.put_line('');
                            for rec_qeustion in c_question_cur(rec_chapter.chapter) loop
                                    v_count := v_count+1;
                                    dbms_output.put_line(v_count ||') '|| rec_qeustion.question); 
                                    get_answer(rec_qeustion.questionid);
                                    check_answer(rec_qeustion.questionid);
                                    sumary_question(rec_qeustion.questionid);
                                    dbms_output.put_line('');
                            end loop;
                            end  loop;
    end analyze_test;
        
    procedure check_answer(p_questionno questiontest.questionid%type)is
            cursor c_check_answer(p_questionno questiontest.questionid%type)is
                    select answer
                    from answerbank
                    where ANSWERTYPE = 1 and questionid = p_questionno ;
             begin
                for rec_answer in c_check_answer(p_questionno) loop
                dbms_output.put_line('The correct answer is : '||rec_answer.answer );
                end loop;
    end check_answer;

    function checking_score ( p_registrationno registration.registrationno%type)return type_count is
            cursor c_get_ans(p_registrationno registration.registrationno%type) is
                    select testanswer,answer 
                    from questiontest q join registration r on q.registrationno = r.registrationno
                    where  q.registrationno = p_registrationno;
            v_result boolean ;
            v_correct number:=0;
            v_false number :=0;
            begin
                    for rec_check in c_get_ans(p_registrationno) loop
                            v_result := true_false_answer (rec_check.testanswer,rec_check.answer);
                            if v_result  then
                                    v_correct := v_correct+1;
                            else 
                                    v_false := v_false+1;
                            end if;
                    end loop;
                            return type_count(v_correct,v_false);
    end  checking_score;
    
    procedure counting_tester_choice(p_questionno  questiontest.questionid%TYPE := null,p_code  number := null)  is
            cursor c_usernum_cur (p_questionno questiontest.questionid%TYPE)is
                    select q.questionid,r.registrationno,q.testanswer,q.a_id,q.b_id,q.c_id,q.d_id
                    from questiontest q
                    JOIN registration r on q.registrationno=r.registrationno
                    where questionid=p_questionno
                    order BY q.questionid ASC;
                    
            v_code number;
            v_count number :=0 ;
            v_c number :=0 ;
            begin 
                    for v_rec in c_usernum_cur(p_questionno) loop
                        v_c := v_c +1;
                        
                        if UPPER(v_rec.TESTANSWER) = 'A'   then
                            v_code := v_rec.a_id;
                         ELSIF UPPER(v_rec.TESTANSWER) = 'B' then    
                              v_code := v_rec.b_id;
                        ELSIF UPPER(v_rec.TESTANSWER) = 'C' then    
                              v_code := v_rec.c_id;
                        ELSIF UPPER(v_rec.TESTANSWER) = 'D' then    
                              v_code := v_rec.d_id;
                        end if; 
                        
                        if  v_code = p_code then
                            v_count := v_count + 1;  
                        end if;
                        
                    end loop;
                dbms_output.put_line('  ('||v_count||' tester answered)');
    end ;
    
    procedure get_answer(p_questionno questiontest.questionid%type := null,p_registrationno registration.registrationno%type := null)is
            cursor c_answer_cur (p_questionno questiontest.questionid%type,p_registrationno registration.registrationno%type) is
                    select ab.answer,ab.answerid,ab.questionid ,qt.a_id,qt.b_id,qt.c_id,qt.d_id
                    from answerbank ab join questionbank qb  on ab.questionid = qb.questionid
                    join questiontest qt on qt.questionid = qb.questionid
                    where  qt.registrationno = p_registrationno and qt.questionid = p_questionno;
                
            cursor c_answer2_cur (p_questionno questiontest.questionid%type) is
                    select ab.answer,ab.answerid,ab.questionid
                    from answerbank ab join questionbank qb  on ab.questionid = qb.questionid
                    where qb.questionid = p_questionno;    
            v_choice_number NUMBER :=0;      
            begin

                if p_registrationno is null then
                        for answer_rec in c_answer2_cur(p_questionno) loop
                                        v_choice_number := v_choice_number+1;
                                        dbms_output.put('  '||v_choice_number||') '||answer_rec.answer);
                                        counting_tester_choice(p_questionno,answer_rec.answerid);
                        end loop;
                else
                        for answer_rec in c_answer_cur(p_questionno,p_registrationno) loop
                                if answer_rec.answerid = answer_rec.a_id then
                                        v_choice_number := v_choice_number+1;
                                        dbms_output.put('  '||v_choice_number||') '||answer_rec.answer );
                                        counting_tester_choice(p_questionno, answer_rec.a_id);
                                ELSIF answer_rec.answerid = answer_rec.b_id then
                                        v_choice_number := v_choice_number+1;
                                        dbms_output.put('  '||v_choice_number||') ' ||answer_rec.answer );
                                        counting_tester_choice(p_questionno, answer_rec.b_id);
                                ELSIF answer_rec.answerid = answer_rec.c_id then
                                        v_choice_number := v_choice_number+1;
                                        dbms_output.put('  '||v_choice_number||') '||answer_rec.answer );
                                        counting_tester_choice(p_questionno, answer_rec.c_id);
                                ELSIF answer_rec.answerid = answer_rec.d_id then
                                        v_choice_number := v_choice_number+1;
                                        dbms_output.put('  '||v_choice_number||') '||answer_rec.answer );
                                        counting_tester_choice(p_questionno, answer_rec.d_id);
                                end if;
                        end loop;
                 end if;
    end get_answer;
    
    function true_false_answer(p_answer_user questiontest.answer%type,
                                            p_answer_test questiontest.testanswer%type) return boolean is
            begin
                    if p_answer_user = p_answer_test then
                        return true;
                    else     
                         return false;
                    end if; 
    end true_false_answer;
    
   procedure sumary_question (p_questionid questionbank.questionid%type) is
            cursor c_count_tester_cur (p_questionno questiontest.questionid%type)is
                    select q.questionid,r.registrationno
                    from questiontest q
                    join registration r on q.registrationno=r.registrationno
                    where questionid=p_questionno
                    order BY q.questionid ASC;        
            v_testanswer questiontest.testanswer%type;
            v_answer questiontest.answer%type;
            v_result boolean :=false;
            v_count_correct number:=0;
            v_count_false number :=0;
            v_total_tester  number :=0;
            begin
                    for sum_rec in c_count_tester_cur(p_questionid) loop
                            v_total_tester := v_total_tester+1;
                            select testanswer,answer into v_testanswer,v_answer
                             from questiontest q join registration r on q.registrationno = r.registrationno
                            where questionid = sum_rec.questionid and q.registrationno = sum_rec.registrationno;
                             v_result := true_false_answer (v_testanswer,v_answer);
                            if v_result  then
                                v_count_correct := v_count_correct+1;
                            else 
                                v_count_false := v_count_false+1;
                            end if;
                     end loop;      
                    dbms_output.put_line('Total Tester that tested in this question : '||v_total_tester||', Correct : '|| v_count_correct||', False  : ' || v_count_false);
--                    dbms_output.put_line(' ');
    end  sumary_question;
    
end package_analysis;

set SERVEROUTPUT ON
--test registerno
EXECUTE package_analysis.ANALYZE_TEST(300001);
--test testdaye and subjectcode
EXECUTE package_analysis.ANALYZE_TEST('01-MAY-19','int102');
--test subjectcode
EXECUTE package_analysis.ANALYZE_TEST('int102');

EXECUTE package_analysis.get_answer(4337);
