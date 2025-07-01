using UnityEngine;

public class Animaciq : MonoBehaviour
{
    private SpriteRenderer sr;
    private float posoka;
    private int walk;

    private Dvijenie dvijenie;

    [SerializeField]
    GameObject igra4;

    [SerializeField]
    Sprite[] sprites;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        walk = 0;
        sr = igra4.GetComponent<SpriteRenderer>();
        dvijenie = GameObject.FindGameObjectWithTag("Player").GetComponent<Dvijenie>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void FixedUpdate()
    {
        posoka = Input.GetAxis("Horizontal");
        sr.flipX = posoka < 0 ? true : false;

        if (dvijenie.MidAir())
        {
            sr.sprite = sprites[1];
        }
        else if (posoka > 0.1f || posoka < -0.1f)
        {
            walk += 1;
            walk %= 11;
            sr.sprite = sprites[walk + 2];
        }
        else
        {
            sr.sprite = sprites[0];
            walk = 0;
        }
    }
}
