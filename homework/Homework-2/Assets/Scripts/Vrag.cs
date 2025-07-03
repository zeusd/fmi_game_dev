using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Vrag : MonoBehaviour
{
    private int walk;
    private bool jumping;

    [SerializeField]
    private GameObject guy;

    [SerializeField]
    private Sprite[] sprites;

    [SerializeField]
    private int speed;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        walk = 0;
        jumping = false;
    }

    // Update is called once per frame
    void Update()
    {

    }

    void FixedUpdate()
    {
        List<Collider2D> touches = new List<Collider2D>();
        GetComponent<Collider2D>().Overlap(touches);

        foreach (var col in touches)
        {
            if (col.CompareTag("Player"))
            {
                if (!jumping && IsAbove(col))
                {
                    jumping = true;
                    JumpAttack(col);
                }
                else if (IsBeside(col))
                {
                    WalkAttack(col);
                }

                break;
            }
        }

        if (jumping)
        {
            Vector2 boxPos = guy.transform.position;
            boxPos.y -= 1.1f;
            RaycastHit2D[] raycastHits2D = Physics2D.BoxCastAll(boxPos, new Vector2(1, 1), 0, new Vector2(0, 0));

            foreach (var item in raycastHits2D)
            {
                var col = item.collider.gameObject.name;
                if (!item.collider.gameObject.CompareTag("Player") && col != name && col != guy.name)
                {
                    jumping = false;
                    Calm();
                }
            }
        }
    }

    void OnTriggerEnter2D(Collider2D col)
    {

    }

    void OnTriggerExit2D(Collider2D col)
    {
        if (col.CompareTag("Player"))
        {
            Calm();
        }
    }

    void OnTriggerStay2D(Collider2D col)
    {
     
    }

    bool IsAbove(Collider2D col)
    {
        Vector3 igra4 = col.transform.position;
        Vector3 az = guy.GetComponent<Transform>().position;

        if (igra4.x > az.x - 2 && igra4.x < az.x + 2 && igra4.y > az.y + 1)
        {
            return true;
        }

        return false;
    }

    bool IsBeside(Collider2D col)
    {
        Vector3 igra4 = col.transform.position;
        Vector3 az = guy.GetComponent<Transform>().position;

        if (igra4.y > az.y - 1 && igra4.y < az.y + 1 && igra4.x > az.x - 4 && igra4.x < az.x + 4)
        {
            return true;
        }

        return false;
    }

    void Calm()
    {
        guy.GetComponent<SpriteRenderer>().sprite = sprites[0];
    }

    void JumpAttack(Collider2D col)
    {
        guy.GetComponent<Rigidbody2D>().AddForce(new Vector2(0, 0.3f), ForceMode2D.Impulse);
        guy.GetComponent<SpriteRenderer>().sprite = sprites[1];
    }

    void WalkAttack(Collider2D col)
    {
        Rigidbody2D rb = guy.GetComponent<Rigidbody2D>();
        SpriteRenderer sr = guy.GetComponent<SpriteRenderer>();

        if (col.transform.position.x < guy.GetComponent<Transform>().position.x)
        {
            sr.flipX = true;
            rb.linearVelocity = new Vector2(-speed, rb.linearVelocity.y);
        }
        else
        {
            sr.flipX = false;
            rb.linearVelocity = new Vector2(speed, rb.linearVelocity.y);
        }

        walk %= 2;
        sr.sprite = sprites[walk + 2];
        walk++;
    }
}
